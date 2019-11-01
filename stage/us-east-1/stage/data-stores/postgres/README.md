# RDS Postgres Database

This directory creates an RDS Postgres database. Note that many logical databases can exist on
a single physical database.




## Current configuration

The infrastructure in these templates has been configured as follows:

* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices. Required
  version `>=0.19.0`.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terragrunt.hcl` file.

* **Database Username and Password:** The RDS Databases have been deployed with a master username and password. To get
  access to these (encrypted via [keybase](https://keybase.io)), email support@gruntwork.io.




## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules/data-stores/rds](https://github.com/alliedworld/infrastructure-modules/tree/master/data-stores/rds).
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




## More info

For more info, check out the Readme for this module in [infrastructure-modules/data-stores/rds](https://github.com/alliedworld/infrastructure-modules/tree/master/data-stores/rds).
