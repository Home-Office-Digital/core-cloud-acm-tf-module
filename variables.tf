variable "domain_name" {
  description = "The primary fully qualified domain name (FQDN) for which to request the public certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "Optional - A list of additional fully qualified domain names (SANs) to include on the certificate."
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "The method used to validate the certificate. Only DNS validation is supported by this module."
  type        = string
  default     = "DNS"

  validation {
    condition     = var.validation_method == "DNS"
    error_message = "validation_method must be \"DNS\"."
  }
}

variable "hosted_zone_id" {
  description = "The Route53 hosted zone ID in which to create the DNS validation records. Required when validation_record_creation_enabled is true."
  type        = string
  default     = null
}

variable "validation_record_creation_enabled" {
  description = "Whether the module should create the Route53 DNS validation records and the aws_acm_certificate_validation resource. Set to false when DNS is managed externally."
  type        = bool
  default     = true
}

variable "key_algorithm" {
  description = "The algorithm and size of the public key pair that AWS ACM uses to create the certificate, eg RSA_2048, EC_prime256v1."
  type        = string
  default     = "RSA_2048"
}

variable "renewal_monitoring_enabled" {
  description = "Whether to create a CloudWatch alarm that monitors the certificate DaysToExpiry metric."
  type        = bool
  default     = true
}

variable "renewal_alarm_threshold_days" {
  description = "The number of days to expiry below which the renewal CloudWatch alarm fires."
  type        = number
  default     = 14
}

variable "renewal_alarm_sns_topic_arns" {
  description = "Optional - A list of SNS topic ARNs to notify via the renewal CloudWatch alarm actions."
  type        = list(string)
  default     = []
}

variable "cc_tags" {
  description = "The mandatory Core Cloud enforced tags for costing and identification. All attributes are required."
  type = object({
    cost_centre      = string
    account_code     = string
    portfolio_id     = string
    project_id       = string
    service_id       = string
    environment_type = string
    owner_business   = string
    budget_holder    = string
  })
}

variable "tags" {
  description = "Optional - A map of additional tags to merge onto the Core Cloud enforced tags."
  type        = map(string)
  default     = {}
}
