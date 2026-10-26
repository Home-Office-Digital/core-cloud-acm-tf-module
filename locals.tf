locals {
  # Map the snake_case cc_tags input to the hyphenated Core Cloud tag keys.
  common_tags = {
    cost-centre      = var.cc_tags.cost_centre
    account-code     = var.cc_tags.account_code
    portfolio-id     = var.cc_tags.portfolio_id
    project-id       = var.cc_tags.project_id
    service-id       = var.cc_tags.service_id
    environment-type = var.cc_tags.environment_type
    owner-business   = var.cc_tags.owner_business
    budget-holder    = var.cc_tags.budget_holder
  }

  # common_tags last so the enforced cc_tags can't be overridden by var.tags.
  tags = merge(var.tags, local.common_tags)

  # The set of domains to validate. A wildcard and its apex share a single
  # validation CNAME, so the leading "*." is dropped and the result deduped.
  validation_domains = toset([
    for domain in concat([var.domain_name], var.subject_alternative_names) :
    trimprefix(domain, "*.")
  ])

  # The DNS validation record for each domain, drawn from the certificate's
  # validation options.
  validation_records = {
    for domain in local.validation_domains : domain => one(distinct([
      for option in aws_acm_certificate.this.domain_validation_options : {
        name  = option.resource_record_name
        value = option.resource_record_value
        type  = option.resource_record_type
      }
      if trimprefix(option.domain_name, "*.") == domain
    ]))
  }
}
