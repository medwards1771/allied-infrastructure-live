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
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//security/cloudtrail?ref=v0.0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  cloudtrail_trail_name = "allied-world"
  s3_bucket_name        = "allied-world-security-cloudtrail"

  num_days_after_which_archive_log_data = 30
  num_days_after_which_delete_log_data  = 365

  kms_key_administrator_iam_arns = [
    "arn:aws:iam::296216577101:user/jeff.devine@awacservices.com",
  ]
  kms_key_user_iam_arns = [
    "arn:aws:iam::296216577101:user/jeff.devine@awacservices.com",
  ]
  allow_cloudtrail_access_with_iam = true

  s3_bucket_already_exists = false
  external_aws_account_ids_with_write_access = [
    "805321607950",

    "608056288583",

    "451511469926",

    "645769240473",
  ]

  # Only set this to true if, when running 'terragrunt destroy,' you want to delete the contents of the S3 bucket that
  # stores the CloudTrail logs. Note that you must set this to true and run 'terragrunt apply' FIRST, before running 'destroy'!
  force_destroy = false
}
