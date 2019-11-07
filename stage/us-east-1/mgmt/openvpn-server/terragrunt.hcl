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
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//mgmt/openvpn-server?ref=v0.0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# When using the terragrunt xxx-all commands (e.g., apply-all, plan-all), deploy these dependencies before this module
dependencies {
  paths = [
    "../vpc",
    "../../_global/kms-master-key",
    "../../../_global/route53-public",
    "../../stage/vpc",
    "../../_global/sns-topics",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  name          = "openvpn"
  instance_type = "t2.medium"
  ami           = "ami-02c09f4cfd357c431"

  domain_name          = "vpn.aw-stage.cloud"
  create_route53_entry = true

  request_queue_name    = "openvpn-request-queue"
  revocation_queue_name = "openvpn-revocation-queue"

  backup_bucket_name = "allied-world-stage-openvpn-backup"

  # VPN clients will be assigned (internal) IP addresses from this range of IPs
  vpn_subnet = "172.16.1.0 255.255.255.0"

  # The OpenVPN server is configured in split tunnel mode, so only specific IP address ranges will be routed over the VPN
  # connection. That way, only requests for internal AWS resources go over VPN, and not your normal web traffic (e.g.
  # GMail, Spotify, YouTube, etc). Here, we configure the module with the names of all of our VPCs, so all traffic to the
  # IP address ranges of those VPCs will be sent over VPN.
  current_vpc_name = "mgmt"
  other_vpc_names  = ["stage"]

  ca_country  = "BM"
  ca_state    = "Pembroke"
  ca_locality = "Hamilton"
  ca_org      = "Allied World"
  ca_org_unit = "IT"
  ca_email    = "info@awac.com"

  keypair_name = "stage-openvpn-us-east-1-v1"
  allow_ssh_from_cidr_list = [
    "0.0.0.0/0", # TODO: fill in your office IP address(es) here!
  ]

  external_account_arns = [
    "arn:aws:iam::296216577101:root", # security account
  ]

  external_account_ssh_grunt_role_arn = "arn:aws:iam::296216577101:role/allow-ssh-grunt-access-from-other-accounts"

  # Only set this to true if, when running 'terragrunt destroy,' you want to delete the contents of the S3 bucket used to
  # backup the PKI infrastructure for your VPN server. Note that you must set this to true and run 'terragrunt apply'
  # FIRST, before running 'destroy'!
  force_destroy = false
}
