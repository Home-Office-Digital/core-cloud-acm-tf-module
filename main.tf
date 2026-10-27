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
  for_each = var.validation_record_creation_enabled ? local.validation_records : {}

  name            = each.value.name
  records         = [each.value.value]
  type            = each.value.type
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

  # Certificate id from the ARN keeps the alarm name unique when two certs
  # share a domain_name.
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
