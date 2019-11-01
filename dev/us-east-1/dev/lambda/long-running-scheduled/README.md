# Long-running, Scheduled Lambda Example

This is an example of a lambda function that runs on a scheduled basis (similar to a cron job). To handle long-running
jobs, which take longer than Lambda's 5 minute execution limit, this lambda function runs a Task in an ECS Cluster.

Under the hood, this is implemented using Terraform modules and Lambda code from 
[infrastructure-modules/lambda/long-running-scheduled](https://github.com/alliedworld/infrastructure-modules/tree/master/lambda/long-running-scheduled).






## Current configuration

The infrastructure in these templates has been configured as follows:

* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices. Required
  version `>=0.19.0`.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terragrunt.hcl` file.





## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules/lambda/long-running-scheduled](https://github.com/alliedworld/infrastructure-modules/tree/master/lambda/long-running-scheduled).
When you run Terragrunt, it finds the URL of this module in the `terragrunt.hcl` file, downloads the Terraform code into
a temporary folder, copies all the files in the current working directory (including `terragrunt.hcl`) into the
temporary folder, and runs your Terraform command in that temporary folder.

See the [Terragrunt Remote Terraform configurations
documentation](https://github.com/gruntwork-io/terragrunt#remote-terraform-configurations) for more info.




## Applying changes

To deploy a new version of the lambda function, you first need to build the function's deployment package:

1. Install [Docker](https://www.docker.com/).
1. Check out [infrastructure-modules/lambda/long-running-scheduled](https://github.com/alliedworld/infrastructure-modules/tree/master/lambda/long-running-scheduled).
1. Run `./src/build.sh`.

Once the deployment package has been built, you can deploy the new code to AWS Lambda as follows:

1. Make sure [Terraform](https://www.terraform.io/) and [Terragrunt](https://github.com/gruntwork-io/terragrunt) are
   installed.
1. Configure the secrets specified at the top of `terragrunt.hcl` as environment variables. In particular, you need
   to set `TF_VAR_source_path` to the path outputted by `build.sh`.
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.




## More info

For more info, check out the Readme for this module in [infrastructure-modules/lambda/long-running-scheduled](https://github.com/alliedworld/infrastructure-modules/tree/master/lambda/long-running-scheduled).
