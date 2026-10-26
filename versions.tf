terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66"
      # This is a child module, so the default `aws` provider (and the region it
      # is configured with) is inherited from the caller. CloudFront certificates
      # MUST be created in us-east-1, so the module declares an additional
      # `aws.us_east_1` configuration alias. The caller passes a us-east-1 aliased
      # provider for CloudFront certificates, or the module's default provider
      # when a us-east-1 certificate is not required.
      configuration_aliases = [aws.us_east_1]
    }
  }
  required_version = ">= 1.7.5"
}
