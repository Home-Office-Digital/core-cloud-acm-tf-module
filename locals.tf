locals {
  # Core Cloud mandatory tags, mapping the snake_case cc_tags input to the
  # hyphenated keys applied to every resource. Merged with any extra tags.
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

  # Effective tags applied to every resource: optional caller-supplied tags
  # merged with the mandatory Core Cloud tags applied LAST, so the enforced
  # cc_tags always win and cannot be overridden by caller tags.
  tags = merge(var.tags, local.common_tags)

  # The distinct set of domains requiring a DNS validation record. Derived
  # from the plan-time inputs (domain_name + SANs) so it can key for_each.
  # A wildcard (*.example.com) and its apex (example.com) validate against an
  # identical CNAME, so we strip the leading "*." and dedupe via toset to
  # avoid creating two Route53 records with the same name.
  validation_domains = toset([
    for domain in concat([var.domain_name], var.subject_alternative_names) :
    trimprefix(domain, "*.")
  ])
}
