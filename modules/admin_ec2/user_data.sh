#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/skyline-admin-user-data.log | logger -t skyline-admin-user-data -s 2>/dev/console) 2>&1

export HOME=/root

LINUX_USER="ec2-user"
EKS_SETUP_SCRIPT="/usr/local/bin/skyline-setup-eks.sh"

dnf update -y
dnf install -y git jq sudo tar gzip unzip docker

if dnf list mariadb105 >/dev/null 2>&1; then
  dnf install -y mariadb105
else
  dnf install -y mariadb
fi

groupadd -f docker
usermod -aG docker "$${LINUX_USER}"

if id ssm-user >/dev/null 2>&1; then
  usermod -aG docker ssm-user
fi

systemctl enable docker.service
systemctl enable containerd.service
systemctl start docker.service

arch="$(uname -m)"
case "$${arch}" in
  x86_64)
    kubectl_arch="amd64"
    ;;
  aarch64)
    kubectl_arch="arm64"
    ;;
  *)
    echo "Unsupported architecture for kubectl install: $${arch}" >&2
    exit 1
    ;;
esac

kubectl_tmp_dir="$(mktemp -d)"
trap 'rm -rf "$${kubectl_tmp_dir}"' EXIT

pushd "$${kubectl_tmp_dir}"
kubectl_version="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
curl -LO "https://dl.k8s.io/release/$${kubectl_version}/bin/linux/$${kubectl_arch}/kubectl"
curl -LO "https://dl.k8s.io/release/$${kubectl_version}/bin/linux/$${kubectl_arch}/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
popd
rm -rf "$${kubectl_tmp_dir}"

helm_tmp_dir="$(mktemp -d)"
helm_version="v4.1.1"
pushd "$${helm_tmp_dir}"
curl -LO "https://get.helm.sh/helm-$${helm_version}-linux-$${kubectl_arch}.tar.gz"
tar -xzf "helm-$${helm_version}-linux-$${kubectl_arch}.tar.gz"
install -o root -g root -m 0755 "linux-$${kubectl_arch}/helm" /usr/local/bin/helm
popd
rm -rf "$${helm_tmp_dir}"

eksctl_tmp_dir="$(mktemp -d)"
eksctl_platform="Linux_$${kubectl_arch}"
pushd "$${eksctl_tmp_dir}"
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$${eksctl_platform}.tar.gz"
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep "$${eksctl_platform}" | sha256sum --check
tar -xzf "eksctl_$${eksctl_platform}.tar.gz"
install -o root -g root -m 0755 eksctl /usr/local/bin/eksctl
popd
rm -rf "$${eksctl_tmp_dir}"

cat > "$${EKS_SETUP_SCRIPT}" <<'EOF'
${eks_setup_script_contents}
EOF
chmod 0755 "$${EKS_SETUP_SCRIPT}"

echo "Run '$${EKS_SETUP_SCRIPT}' after the ephemeral EKS stack is created."

docker --version
systemctl is-active docker.service
aws --version
helm version
eksctl version
kubectl version --client --output=yaml
