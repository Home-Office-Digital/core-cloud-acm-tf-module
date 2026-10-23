# The outputs.tf contains the output definitions for this module. Outputs are
# made available to the configuration consuming the module.

output "certificate_arn" {
  description = "The ARN of the ACM certificate."
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "The primary domain name of the ACM certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "The status of the ACM certificate."
  value       = aws_acm_certificate.this.status
}

output "domain_validation_options" {
  description = "The set of domain validation options for the certificate, for consumers managing DNS validation records externally."
  value       = aws_acm_certificate.this.domain_validation_options
}

output "validation_certificate_arn" {
  description = "The ARN of the validated certificate when validation is enabled, otherwise the certificate ARN."
  value       = var.validation_record_creation_enabled ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
}

output "renewal_alarm_arn" {
  description = "The ARN of the renewal CloudWatch alarm, or null when renewal monitoring is disabled."
  value       = var.renewal_monitoring_enabled ? aws_cloudwatch_metric_alarm.renewal[0].arn : null
}
