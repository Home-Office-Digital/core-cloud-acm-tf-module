All notable changes to this project will be documented in this file. This will provide a record of all notable module updates with each new release. Semantic versioning (https://semver.org/) must be adhered to for all Core Cloud modules.

eg:

### [0.0.1] 2026-10-20

  * Initial tag created for Core Cloud ACM Terraform module. Provisions public TLS certificates via AWS Certificate Manager (ACM) with DNS validation, optional Route53 validation record creation, subject alternative names (SANs), and optional CloudWatch renewal monitoring on the `DaysToExpiry` metric.
  * Interface notes for this first release:
    * Certificates use `validation_method = "DNS"`. When `validation_record_creation_enabled` is true the module creates the Route53 validation records and an `aws_acm_certificate_validation` resource; when false the caller manages DNS validation externally using the `domain_validation_options` output.
    * CloudFront certificates must be created in `us-east-1`. The module declares an `aws.us_east_1` provider configuration alias that the caller must satisfy via the module block `providers` mapping.
    * Tags follow the Core Cloud `cc_tags` convention (8-key snake_case object) mapped to the hyphenated resource-tag keys via the `common_tags` local, merged with any optional `tags`.
