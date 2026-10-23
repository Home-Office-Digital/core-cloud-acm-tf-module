# The main.tf contains the main set of configuration for this module. It
# provisions a public TLS certificate via AWS ACM, optionally creates the
# Route53 DNS validation records and completes validation, and optionally
# monitors certificate renewal via a CloudWatch alarm.

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  key_algorithm             = var.key_algorithm

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  # for_each is keyed on the plan-time-static set of distinct domains
  # (local.validation_domains, computed in locals.tf) rather than on the
  # apply-time aws_acm_certificate.this.domain_validation_options set, which
  # is unknown until apply and so cannot drive for_each keys. A wildcard SAN
  # (*.example.com) and its apex (example.com) produce an identical validation
  # CNAME, so local.validation_domains strips the leading "*." and dedupes,
  # yielding a single record per distinct validation name.
  for_each = var.validation_record_creation_enabled ? local.validation_domains : toset([])

  # Look up the apply-time validation option for this domain. A cert covering
  # both an apex (example.com) and its wildcard (*.example.com) returns two
  # domain_validation_options that both normalize to the same key and carry an
  # identical validation CNAME, so the filter matches two entries. distinct()
  # collapses those identical values to one before one() enforces singularity.
  name = one(distinct([
    for option in aws_acm_certificate.this.domain_validation_options :
    option.resource_record_name if trimprefix(option.domain_name, "*.") == each.value
  ]))
  records = [one(distinct([
    for option in aws_acm_certificate.this.domain_validation_options :
    option.resource_record_value if trimprefix(option.domain_name, "*.") == each.value
  ]))]
  type = one(distinct([
    for option in aws_acm_certificate.this.domain_validation_options :
    option.resource_record_type if trimprefix(option.domain_name, "*.") == each.value
  ]))

  allow_overwrite = true
  ttl             = 60
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count = var.validation_record_creation_enabled ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

resource "aws_cloudwatch_metric_alarm" "renewal" {
  count = var.renewal_monitoring_enabled ? 1 : 0

  # Include the certificate's unique id (the final path segment of its ARN)
  # so two certificates for the same domain_name do not collide on alarm name.
  alarm_name          = "${var.domain_name}-${element(split("/", aws_acm_certificate.this.arn), length(split("/", aws_acm_certificate.this.arn)) - 1)}-acm-days-to-expiry"
  alarm_description   = "Fires when the ACM certificate ${aws_acm_certificate.this.arn} for ${var.domain_name} has fewer than ${var.renewal_alarm_threshold_days} days until expiry."
  namespace           = "AWS/CertificateManager"
  metric_name         = "DaysToExpiry"
  comparison_operator = "LessThanThreshold"
  threshold           = var.renewal_alarm_threshold_days
  evaluation_periods  = 1
  period              = 86400
  statistic           = "Minimum"
  treat_missing_data  = "breaching"

  dimensions = {
    CertificateArn = aws_acm_certificate.this.arn
  }

  alarm_actions = var.renewal_alarm_sns_topic_arns

  tags = local.tags
}
