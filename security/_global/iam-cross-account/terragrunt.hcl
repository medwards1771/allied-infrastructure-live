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
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//security/iam-cross-account?ref=v0.0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# If you delete iam-cross-account, you may lose all IAM access to this account, so we set prevent destroy here to
# prevent accidental lock out. If you really want to run destroy on this module, remove this flag.
prevent_destroy = true

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  should_require_mfa = true

  dev_permitted_services = []

  allow_read_only_access_from_other_account_arns = []

  allow_billing_access_from_other_account_arns = []

  allow_ssh_grunt_access_from_other_account_arns = [
    "arn:aws:iam::451511469926:root", # shared-services
    "arn:aws:iam::608056288583:root", # prod
    "arn:aws:iam::645769240473:root", # stage
    "arn:aws:iam::805321607950:root", # dev
  ]

  allow_dev_access_from_other_account_arns = []

  allow_full_access_from_other_account_arns = []
}
