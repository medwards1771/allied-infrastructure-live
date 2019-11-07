# Dev Application Load Balancer (ALB)

This directory creates an [Application Load Balancer](http://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
(ALB) in the dev VPC that can be used to route requests to an ECS Cluster or Auto Scaling Group. Under the
hood, this is implemented using the Gruntwork [alb module](https://github.com/gruntwork-io/module-load-balancer/tree/master/modules/alb).

Note that a single ALB is designed to be shared among multiple ECS Clusters, ECS Services or Auto Scaling Groups, in
contrast to an ELB ("Classic Load Balancer") which is typically associatd with a single service. For this reason, the ALB
 is created separately from an ECS Cluster, ECS Service, or Auto Scaling Group.


## Current configuration

The infrastructure in these templates has been configured as follows:

* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices. Required
  version `>=0.19.0`.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terragrunt.hcl` file.



## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules/networking/alb](https://github.com/alliedworld/infrastructure-modules/tree/master/networking/alb).
When you run Terragrunt, it finds the URL of this module in the `terragrunt.hcl` file, downloads the Terraform code into
a temporary folder, copies all the files in the current working directory (including `terragrunt.hcl`) into the
temporary folder, and runs your Terraform command in that temporary folder.

See the [Terragrunt Remote Terraform configurations
documentation](https://github.com/gruntwork-io/terragrunt#remote-terraform-configurations) for more info.

## Applying changes

To apply changes to the templates in this folder, do the following:

1. Make sure [Terraform](https://www.terraform.io/) and [Terragrunt](https://github.com/gruntwork-io/terragrunt) are
   installed.
1. Configure the secrets specified at the top of `terragrunt.hcl` as environment variables.
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.

## Core concepts

To understand core concepts like what is an ALB, ELB vs. ALB, and how to use an ALB with an ECS Cluster and ECS Service,
the [alb module documentation](https://github.com/gruntwork-io/module-load-balancer/tree/master/modules/alb).
