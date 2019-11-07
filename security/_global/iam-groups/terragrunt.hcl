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
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//security/iam-groups?ref=v0.0.1"
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
  should_require_mfa = true

  iam_groups_for_cross_account_access = [
    {
      group_name   = "_account.dev-auto-deploy"
      iam_role_arn = "arn:aws:iam::805321607950:role/allow-auto-deploy-from-other-accounts"
    },
    {
      group_name   = "_account.dev-full-access"
      iam_role_arn = "arn:aws:iam::805321607950:role/allow-full-access-from-other-accounts"
    },
    {
      group_name   = "_account.dev-openvpn-admins"
      iam_role_arn = "arn:aws:iam::805321607950:role/openvpn-allow-certificate-revocations-for-external-accounts"
    },
    {
      group_name   = "_account.dev-openvpn-users"
      iam_role_arn = "arn:aws:iam::805321607950:role/openvpn-allow-certificate-requests-for-external-accounts"
    },
    {
      group_name   = "_account.dev-read-only"
      iam_role_arn = "arn:aws:iam::805321607950:role/allow-read-only-access-from-other-accounts"
    },
    {
      group_name   = "_account.prod-auto-deploy"
      iam_role_arn = "arn:aws:iam::608056288583:role/allow-auto-deploy-from-other-accounts"
    },
    {
      group_name   = "_account.prod-full-access"
      iam_role_arn = "arn:aws:iam::608056288583:role/allow-full-access-from-other-accounts"
    },
    {
      group_name   = "_account.prod-openvpn-admins"
      iam_role_arn = "arn:aws:iam::608056288583:role/openvpn-allow-certificate-revocations-for-external-accounts"
    },
    {
      group_name   = "_account.prod-openvpn-users"
      iam_role_arn = "arn:aws:iam::608056288583:role/openvpn-allow-certificate-requests-for-external-accounts"
    },
    {
      group_name   = "_account.prod-read-only"
      iam_role_arn = "arn:aws:iam::608056288583:role/allow-read-only-access-from-other-accounts"
    },
    {
      group_name   = "_account.shared-services-auto-deploy"
      iam_role_arn = "arn:aws:iam::451511469926:role/allow-auto-deploy-from-other-accounts"
    },
    {
      group_name   = "_account.shared-services-full-access"
      iam_role_arn = "arn:aws:iam::451511469926:role/allow-full-access-from-other-accounts"
    },
    {
      group_name   = "_account.shared-services-openvpn-admins"
      iam_role_arn = "arn:aws:iam::451511469926:role/openvpn-allow-certificate-revocations-for-external-accounts"
    },
    {
      group_name   = "_account.shared-services-openvpn-users"
      iam_role_arn = "arn:aws:iam::451511469926:role/openvpn-allow-certificate-requests-for-external-accounts"
    },
    {
      group_name   = "_account.shared-services-read-only"
      iam_role_arn = "arn:aws:iam::451511469926:role/allow-read-only-access-from-other-accounts"
    },
    {
      group_name   = "_account.stage-auto-deploy"
      iam_role_arn = "arn:aws:iam::645769240473:role/allow-auto-deploy-from-other-accounts"
    },
    {
      group_name   = "_account.stage-full-access"
      iam_role_arn = "arn:aws:iam::645769240473:role/allow-full-access-from-other-accounts"
    },
    {
      group_name   = "_account.stage-openvpn-admins"
      iam_role_arn = "arn:aws:iam::645769240473:role/openvpn-allow-certificate-revocations-for-external-accounts"
    },
    {
      group_name   = "_account.stage-openvpn-users"
      iam_role_arn = "arn:aws:iam::645769240473:role/openvpn-allow-certificate-requests-for-external-accounts"
    },
    {
      group_name   = "_account.stage-read-only"
      iam_role_arn = "arn:aws:iam::645769240473:role/allow-read-only-access-from-other-accounts"
    }
  ]
  cross_account_access_all_group_name = "_account.all"

  should_create_iam_group_billing                = false
  should_create_iam_group_developers             = false
  should_create_iam_group_read_only              = true
  should_create_iam_group_use_existing_iam_roles = false
  should_create_iam_group_auto_deploy            = false
  iam_group_names_ssh_grunt_sudo_users = [
    "ssh-grunt-sudo-users",
  ]
  iam_group_names_ssh_grunt_users = [
    "ssh-grunt-users",
    "bastion-only-ssh-grunt-users",
  ]
}
