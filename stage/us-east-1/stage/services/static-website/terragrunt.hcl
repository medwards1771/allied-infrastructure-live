# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//services/static-website?ref=v0.0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# When using the terragrunt xxx-all commands (e.g., apply-all, plan-all), deploy these dependencies before this module
dependencies {
  paths = [
    "../../../../_global/route53-public",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  website_domain_name         = "static.aw-stage.cloud"
  create_route53_entry        = true
  acm_certificate_domain_name = "*.aw-stage.cloud"

  # CloudFront cache settings
  default_ttl = 30
  max_ttl     = 60
  min_ttl     = 0

  # Only set this to true if, when running 'terragrunt destroy,' you want to delete the contents of the S3 buckets that
  # store the website, redirects, and access logs. Note that you must set this to true and run 'terragrunt apply' FIRST,
  # before running 'destroy'!
  force_destroy = false
}
