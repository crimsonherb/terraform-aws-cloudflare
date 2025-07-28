terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-bucket-joma-2025"
    key          = "cloudflare/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
