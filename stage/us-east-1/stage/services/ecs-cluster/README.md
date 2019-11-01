# Stage ECS Cluster

This directory creates an [EC2 Container Service
Cluster](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_clusters.html) in the stage VPC that
can be used to run Docker containers. Under the hood, this is implemented using Terraform modules from
[infrastructure-modules/services/ecs-cluster](https://github.com/alliedworld/infrastructure-modules/tree/master/services/ecs-cluster).




## Current configuration

The infrastructure in these templates has been configured as follows:

* **ssh-grunt**: We have installed [ssh-grunt](https://github.com/gruntwork-io/module-security/tree/master/modules/ssh-grunt)
  on the EC2 Instances in the ECS Cluster, so you can SSH to them using your IAM username and a public key uploaded to
  your IAM  account. Check out the [ssh-grunt docs](https://github.com/gruntwork-io/module-security/tree/master/modules/ssh-grunt)
  for more info.
* **SSH Key Pair**: The EC2 Instances have also been configured to allow SSH access for the `ec2-user` user using the
  Key Pair `stage-services-us-east-1-v1`. *This should only be used as an emergency backup* (e.g. if for some reason `ssh-grunt`
  is not working). Only trusted administrators should have access to this Key Pair. If you don't have access to it,
  email support@gruntwork.io and we will share it with you securely (e.g. using [Keybase](http://keybase.io/)).
* **AMI**: The AMI that is running on each ECS Node is created from the [Packer](https://www.packer.io/) template
  [infrastructure-modules/services/ecs-cluster/packer/ecs-node.json](https://github.com/alliedworld/infrastructure-modules/tree/master/services/ecs-cluster/packer/ecs-node.json).
* **Terragrunt**: Instead of using Terraform directly, we are using a wrapper called
  [Terragrunt](https://github.com/gruntwork-io/terragrunt) that provides locking and enforces best practices. Required
  version `>=0.19.0`.
* **Terraform state**: We are using [Terraform Remote State](https://www.terraform.io/docs/state/remote/), which
  means the Terraform state files (the `.tfstate` files) are stored in an S3 bucket. If you use Terragrunt, it will
  automatically manage remote state for you based on the settings in the `terragrunt.hcl` file.




## Where is the Terraform code?

All the Terraform code for this module is defined in [infrastructure-modules/services/ecs-cluster](https://github.com/alliedworld/infrastructure-modules/tree/master/services/ecs-cluster).
When you run Terragrunt, it finds the URL of this module in the `terragrunt.hcl` file, downloads the Terraform code into
a temporary folder, copies all the files in the current working directory (including `terragrunt.hcl`) into the
temporary folder, and runs your Terraform command in that temporary folder.

See the [Terragrunt Remote Terraform configurations
documentation](https://github.com/gruntwork-io/terragrunt#remote-terraform-configurations) for more info.




## How do you deploy updates to the cluster?

If you want to update the EC2 instances running in the ECS cluster (e.g. roll out a new AMI), you must use the
`roll-out-ecs-cluster-update.py` script in the Gruntwork
[ecs-module](https://github.com/gruntwork-io/module-ecs/tree/master/modules/ecs-cluster). Check out the
[How do you make changes to the EC2 Instances in the
cluster?](https://github.com/gruntwork-io/module-ecs/tree/master/modules/ecs-cluster#how-do-you-make-changes-to-the-ec2-instances-in-the-cluster)
documentation for details.





## More info

For more info, check out the Readme for this module in [infrastructure-modules/services/ecs-cluster](https://github.com/alliedworld/infrastructure-modules/tree/master/services/ecs-cluster).
