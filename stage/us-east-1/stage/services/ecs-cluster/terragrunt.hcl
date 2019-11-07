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
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//services/ecs-cluster?ref=v0.0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# When using the terragrunt xxx-all commands (e.g., apply-all, plan-all), deploy these dependencies before this module
dependencies {
  paths = [
    "../../vpc",
    "../../../mgmt/openvpn-server",
    "../../../_global/kms-master-key",
    "../../networking/alb-public",
    "../../networking/alb-internal",
    "../../../_global/sns-topics",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  cluster_name                  = "ecs-stage"
  cluster_instance_ami          = "ami-0b12b155f325b8cbd"
  cluster_instance_keypair_name = "stage-services-us-east-1-v1"

  # Set the max size to double the min size so the extra capacity can be used to do a zero-downtime deployment of updates
  # to the ECS Cluster Nodes (e.g. when you update the AMI). For docs on how to roll out updates to the cluster, see:
  # https://github.com/gruntwork-io/module-ecs/tree/master/modules/ecs-cluster#how-do-you-make-changes-to-the-ec2-instances-in-the-cluster
  cluster_min_size      = 3
  cluster_max_size      = 6
  cluster_instance_type = "t2.micro"

  external_account_ssh_grunt_role_arn = "arn:aws:iam::296216577101:role/allow-ssh-grunt-access-from-other-accounts"

  allow_requests_from_public_alb   = true
  allow_requests_from_internal_alb = true

  # Trigger an alarm if CPU usage is over 90% for 5 minutes
  high_cpu_utilization_threshold = 90
  high_cpu_utilization_period    = 300

  # Trigger an alarm if memory usage is over 90% for 5 minutes
  high_memory_utilization_threshold = 90
  high_memory_utilization_period    = 300

  # Trigger an alarm if disk space usage is over 90% for 5 minutes
  high_disk_utilization_threshold = 90
  high_disk_utilization_period    = 300
}
