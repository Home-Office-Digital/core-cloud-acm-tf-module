terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66"
      # Single default provider; CloudFront callers pass a us-east-1 provider
      # as the default. See the README for provider setup.
    }
  }
  required_version = ">= 1.7.5"
}
