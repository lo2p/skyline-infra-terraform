terraform {
  required_version = "= 1.14.7"

  backend "s3" {
    bucket       = "skyline-terraform"
    key          = "skyline-infra-terraform/persistent/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.45.0"
    }
  }
}
