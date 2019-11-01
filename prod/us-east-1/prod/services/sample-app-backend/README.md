# Sample-App-Backend-Prod

This directory deploys the sample-app-backend-prod in the ECS Cluster in the prod VPC. Under the hood, this
is implemented using Terraform modules from [infrastructure-modules/services/ecs-service-with-alb](https://github.com/alliedworld/infrastructure-modules/tree/master/services/ecs-service-with-alb).




## Current configuration

The infrastructure in these templates has been configured as follows:

* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices. Required
  version `>=0.19.0`.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terragrunt.hcl` file.





## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules/services/ecs-service-with-alb](https://github.com/alliedworld/infrastructure-modules/tree/master/services/ecs-service-with-alb).
When you run Terragrunt, it finds the URL of this module in the `terragrunt.hcl` file, downloads the Terraform code into
a temporary folder, copies all the files in the current working directory (including `terragrunt.hcl`) into the
temporary folder, and runs your Terraform command in that temporary folder.

See the [Terragrunt Remote Terraform configurations
documentation](https://github.com/gruntwork-io/terragrunt#remote-terraform-configurations) for more info.




## Applying changes

To deploy a new version of the service:

1. Make sure [Terraform](https://www.terraform.io/) and [Terragrunt](https://github.com/gruntwork-io/terragrunt) are
   installed.
1. Update the `version` input in `main.tf`.
1. Configure the secrets specified at the top of `terragrunt.hcl` as environment variables.
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.




## More info

For more info, check out the Readme for this module in [infrastructure-modules/services/ecs-service-with-alb](https://github.com/alliedworld/infrastructure-modules/tree/master/services/ecs-service-with-alb).
