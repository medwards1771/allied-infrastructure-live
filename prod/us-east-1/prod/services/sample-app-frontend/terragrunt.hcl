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
  source = "git::ssh://git@github.com/alliedworld/infrastructure-modules.git//services/ecs-service-with-alb?ref=v0.0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# When using the terragrunt xxx-all commands (e.g., apply-all, plan-all), deploy these dependencies before this module
dependencies {
  paths = [
    "../../vpc",
    "../ecs-cluster",
    "../../data-stores/postgres",
    "../../data-stores/memcached",
    "../../networking/alb-public",
    "../../../_global/sns-topics",
    "../../../../us-east-1/_global/sns-topics",
    "../../../_global/kms-master-key",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {

  service_name            = "sample-app-frontend-prod"
  image                   = "451511469926.dkr.ecr.us-east-1.amazonaws.com/sample-app-frontend"
  image_version           = "v1"
  desired_number_of_tasks = 2

  cpu    = 512
  memory = 128

  # Specify the port the Docker container listens on
  container_port = 3000

  # Attach these routing rules to the ALB. These rules configure the ALB to send requests that come in on certain ports
  # and paths to this ECS service.
  alb_listener_rule_configs = [
    {
      port     = 80,
      path     = "/sample-app-frontend*",
      priority = 100
    },
    {
      port     = 443,
      path     = "/sample-app-frontend*",
      priority = 100
    },
  ]

  # The ALB will use this protocol when routing requests to this ECS service
  alb_target_group_protocol = "HTTPS"

  # Backend servies should set this to true to register with the internal ALB, which is only accessible from within the VPC.
  # Frontend services should set this to false to register with the public ALB, which is accessible from the public Internet.
  is_internal_alb = false

  # The ALB will perform a health check to this path and port on this ECS service
  health_check_path     = "/sample-app-frontend/health"
  health_check_protocol = "HTTPS"

  # Call backend services at this port on the internal ALB
  internal_alb_port = 443

  # The sample app looks up the backend URL using these env vars
  internal_alb_env_var_name      = "BACKEND_URL"
  internal_alb_port_env_var_name = "BACKEND_PORT"

  db_remote_state_path = "data-stores/postgres/terraform.tfstate"

  # The sample app looks up the DB URL using this env var
  db_url_env_var_name = "DB_URL"

  memcached_remote_state_path = "data-stores/memcached/terraform.tfstate"

  # The sample app looks up the Memcached URL using this env var
  memcached_url_env_var_name = "MEMCACHED_URL"

  vpc_env_var_name            = "VPC_NAME"
  enable_route53_health_check = true

  # Trigger an alarm if CPU usage is over 90 percent during a 5 minute period
  high_cpu_utilization_threshold = 90
  high_cpu_utilization_period    = 300

  # Trigger an alarm if memory usage is over 90 percent during a 5 minute period
  high_memory_utilization_threshold = 90
  high_memory_utilization_period    = 300
}
