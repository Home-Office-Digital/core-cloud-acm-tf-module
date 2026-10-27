# Core Cloud ACM TF Module

This is a Terraform child module to create and manage public TLS certificates via AWS Certificate Manager (ACM) to be consumed by services such as Application Load Balancers (ALB), CloudFront distributions and OpenSearch custom endpoints.

The module requests a public certificate using DNS validation, and can optionally create the Route53 DNS validation records (and complete validation) for you, or expose the validation options so DNS can be managed externally. It can also create a CloudWatch alarm that monitors the certificate's `DaysToExpiry` metric to give early warning of renewal problems.

## CloudFront and the us-east-1 requirement

> **Important:** ACM certificates attached to a CloudFront distribution MUST be created in `us-east-1`.

This is a child module, so the default `aws` provider (and the region it is configured with) is inherited from the caller. The module also declares an `aws.us_east_1` configuration alias which the caller must satisfy. For a standard `eu-west-2` certificate, point the aliased provider at the same region as the default provider. For a CloudFront certificate, pass a provider configured for `us-east-1` as the module's default `aws` provider.

## Usage

### (a) Standard eu-west-2 certificate with Route53 DNS validation

```hcl
provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "acm" {
  source = "git::https://github.com/Home-Office-Digital/core-cloud-acm-tf-module.git"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain_name               = "example.service.gov.uk"
  subject_alternative_names = ["www.example.service.gov.uk"]
  hosted_zone_id            = "Z0123456789ABCDEFGHIJ"

  cc_tags = {
    cost_centre      = "AB123"
    account_code     = "1234567890"
    portfolio_id     = "portfolio"
    project_id       = "project"
    service_id       = "service"
    environment_type = "dev"
    owner_business   = "owner"
    budget_holder    = "holder"
  }
}
```

### (b) CloudFront certificate using a us-east-1 aliased provider

CloudFront requires the certificate in `us-east-1`, so pass a `us-east-1` provider as the module's default `aws` provider.

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "acm_cloudfront" {
  source = "git::https://github.com/Home-Office-Digital/core-cloud-acm-tf-module.git"

  providers = {
    aws           = aws.us_east_1
    aws.us_east_1 = aws.us_east_1
  }

  domain_name    = "cdn.example.service.gov.uk"
  hosted_zone_id = "Z0123456789ABCDEFGHIJ"

  cc_tags = {
    cost_centre      = "AB123"
    account_code     = "1234567890"
    portfolio_id     = "portfolio"
    project_id       = "project"
    service_id       = "service"
    environment_type = "dev"
    owner_business   = "owner"
    budget_holder    = "holder"
  }
}
```

### Managing DNS validation externally

Set `validation_record_creation_enabled = false` to skip creating Route53 records and the validation resource. The `domain_validation_options` output then provides the records required to validate the certificate in an externally managed zone.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.40 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudwatch_metric_alarm.renewal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The primary fully qualified domain name (FQDN) for which to request the public certificate. | `string` | n/a | yes |
| <a name="input_cc_tags"></a> [cc\_tags](#input\_cc\_tags) | The mandatory Core Cloud enforced tags for costing and identification. All attributes are required. | <pre>object({<br>    cost_centre      = string<br>    account_code     = string<br>    portfolio_id     = string<br>    project_id       = string<br>    service_id       = string<br>    environment_type = string<br>    owner_business   = string<br>    budget_holder    = string<br>  })</pre> | n/a | yes |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | Optional - A list of additional fully qualified domain names (SANs) to include on the certificate. | `list(string)` | `[]` | no |
| <a name="input_validation_method"></a> [validation\_method](#input\_validation\_method) | The method used to validate the certificate. Only DNS validation is supported by this module. | `string` | `"DNS"` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | The Route53 hosted zone ID in which to create the DNS validation records. Required when validation\_record\_creation\_enabled is true. | `string` | `null` | no |
| <a name="input_validation_record_creation_enabled"></a> [validation\_record\_creation\_enabled](#input\_validation\_record\_creation\_enabled) | Whether the module should create the Route53 DNS validation records and the aws\_acm\_certificate\_validation resource. Set to false when DNS is managed externally. | `bool` | `true` | no |
| <a name="input_key_algorithm"></a> [key\_algorithm](#input\_key\_algorithm) | The algorithm and size of the public key pair that AWS ACM uses to create the certificate, eg RSA\_2048, EC\_prime256v1. | `string` | `"RSA_2048"` | no |
| <a name="input_renewal_monitoring_enabled"></a> [renewal\_monitoring\_enabled](#input\_renewal\_monitoring\_enabled) | Whether to create a CloudWatch alarm that monitors the certificate DaysToExpiry metric. | `bool` | `true` | no |
| <a name="input_renewal_alarm_threshold_days"></a> [renewal\_alarm\_threshold\_days](#input\_renewal\_alarm\_threshold\_days) | The number of days to expiry below which the renewal CloudWatch alarm fires. | `number` | `14` | no |
| <a name="input_renewal_alarm_sns_topic_arns"></a> [renewal\_alarm\_sns\_topic\_arns](#input\_renewal\_alarm\_sns\_topic\_arns) | Optional - A list of SNS topic ARNs to notify via the renewal CloudWatch alarm actions. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional - A map of additional tags to merge onto the Core Cloud enforced tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | The ARN of the ACM certificate. |
| <a name="output_certificate_domain_name"></a> [certificate\_domain\_name](#output\_certificate\_domain\_name) | The primary domain name of the ACM certificate. |
| <a name="output_certificate_status"></a> [certificate\_status](#output\_certificate\_status) | The status of the ACM certificate. |
| <a name="output_domain_validation_options"></a> [domain\_validation\_options](#output\_domain\_validation\_options) | The set of domain validation options for the certificate, for consumers managing DNS validation records externally. |
| <a name="output_validation_certificate_arn"></a> [validation\_certificate\_arn](#output\_validation\_certificate\_arn) | The ARN of the validated certificate when validation is enabled, otherwise the certificate ARN. |
| <a name="output_renewal_alarm_arn"></a> [renewal\_alarm\_arn](#output\_renewal\_alarm\_arn) | The ARN of the renewal CloudWatch alarm, or null when renewal monitoring is disabled. |
<!-- END_TF_DOCS -->
