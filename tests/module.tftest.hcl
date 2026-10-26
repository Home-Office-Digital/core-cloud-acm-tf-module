mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

run "module_test_scenario_1_tags" {
  command = plan

  variables {
    domain_name    = "example.service.gov.uk"
    hosted_zone_id = "Z0123456789ABCDEFGHIJ"

    cc_tags = {
      cost_centre      = "xxx"
      account_code     = "xxx"
      portfolio_id     = "xxx"
      project_id       = "xxx"
      service_id       = "xxx"
      environment_type = "xxx"
      owner_business   = "xxx"
      budget_holder    = "xxx"
    }
  }

  assert {
    condition     = length(aws_acm_certificate.this.tags) == 8
    error_message = "Incorrect number of tags found."
  }

  assert {
    condition = jsonencode(aws_acm_certificate.this.tags) == jsonencode({
      "cost-centre"      = "xxx",
      "account-code"     = "xxx",
      "portfolio-id"     = "xxx",
      "project-id"       = "xxx",
      "service-id"       = "xxx",
      "environment-type" = "xxx",
      "owner-business"   = "xxx",
      "budget-holder"    = "xxx",
    })
    error_message = "Expected tags not found."
  }

  assert {
    condition     = aws_acm_certificate.this.domain_name == "example.service.gov.uk"
    error_message = "Certificate domain name does not match the requested domain."
  }
}
