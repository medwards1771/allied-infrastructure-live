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
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//security/machine-user?ref=v0.0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# When using the terragrunt xxx-all commands (e.g., apply-all, plan-all), deploy these dependencies before this module
dependencies {
  paths = ["../iam-groups"]
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  name = "circle-ci-machine-user"
  allowed_iam_actions = [
    "ecr:*",
  ]
  iam_groups = [
    "_account.dev-auto-deploy",

    "_account.prod-auto-deploy",

    "_account.shared-services-auto-deploy",

    "_account.stage-auto-deploy",
  ]
}
