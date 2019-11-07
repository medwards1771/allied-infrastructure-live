# Build, tests, and deployment (CI/CD)

In the previous section, you [ran the app in the dev environment](04-dev-environment.md), made some changes to the code,
and committed those changes to Git. Now it's time to see what happens to those changes as part of the automated 
continuous integration (CI) and continuous delivery (CD) process that is configured in [CircleCi](https://circleci.com):

* [Trigger a build](#trigger-a-build)
* [Build and test the code](#build-and-test-the-code)
* [Package the code](#package-the-code)
* [Deploy the code](#deploy-the-code)
* [Deploying infrastructure changes](#deploying-infrastructure-changes)



## Trigger a commit hook

* We have configured CircleCi to run a build on every commit and new tag in your Git repos.

* Note *only* changes in version control can kick off a CircleCi build; there is no way to trigger one manually! 




## Build and test the code

* CircleCi is configured to build and test your code using a `circle.yml` file in the root of your repo. Check out the
  [Configuring CircleCI docs](https://circleci.com/docs/1.0/configuration/) for details on what you can configure
  with the `circle.yml` file.

* Any build steps should typically go into `compile` section of `circle.yml`.
  
* Test steps should typically go into the `test` section of `circle.yml`.

* If any of the build steps fails, the entire build will fail, and the followers of that repo will get email 
  notifications.





## Package the code

We package the code as follows:

* Build a new Docker image for the app
* Tag the image with the Git revision (the sha1 hash) of the commit that triggered the build. This makes it easy to 
  track Docker images back to the commits they contain.
* Push the image to [Amazon ECR](https://aws.amazon.com/ecr/) 
* You can now deploy this new Docker image




## Deploy the code

The `deployment` section of `circle.yml` configures the following deployment settings:

* Commits to the master branch are automatically deployed to staging.
* Tags of the format `release-xxx` are automatically deployed to production.

The automated deployment process works as follows:

1. Git clone the [infrastructure-live](https://github.com/alliedworld/infrastructure-live) repo.
1. Update the `version` property in the service's `terragrunt.hcl` file to the new Docker image tag.
1. `git commit` and `git push` the changes to the `infrastructure-live` repo.
1. Run `terragrunt apply` on the Terraform code to deploy the changes.




## Deploying infrastructure changes

The CI/CD system takes care of "routine" deployments, such as deploying a new version of an app. But what about 
deploying other types of infrastructure changes, such as adding a new server cluster or database? To make these sorts
of changes, you'll have to update your Terraform code.
 
Here's the process we recommend:

* [Check out the infrastructure repos](#check-out-the-infrastructure-repos)
* [Update the code](#update-the-code)
* [Test your changes in a sandbox environment](#test-your-changes-in-a-sandbox-environment)
* [Submit a pull request](#submit-a-pull-request)
* [Merge in your changes](#merge-in-your-changes)
* [Release a new version](#release-a-new-version)
* [Promote the new version to prod](#promote-the-new-version-to-prod)


### Check out the infrastructure repos

All of the infrastructure code lives in the [infrastructure-modules](https://github.com/alliedworld/infrastructure-modules) 
and [infrastructure-live](https://github.com/alliedworld/infrastructure-live) repos (see 
[How the code is organized](03-how-code-is-organized.md)).

```bash
git clone git@github.com:alliedworld/infrastructure-modules.git
git clone git@github.com:alliedworld/infrastructure-live.git
```


### Update the code

Make the appropriate changes in either infrastructure-modules or infrastructure-live. 

* If you want to change some settings for an existing module in an environment, make those changes in the 
  `terragrunt.hcl` files in infrastructure-live. 
  
* If you want to change how the underlying modules work or add a new module, make those changes in 
  infrastructure-modules. Note that after those changes are committed, you'll need to release a new 
  version of infrastructure-modules and update infrastructure-live to use that new version
  (both of these steps are described below).    


### Test your changes in a sandbox environment

Every company should have a "sandbox" environment where developers can make Terraform changes without:
 
1. Having to commit those changes to version control.
1. Having to worry that if they break something, it will cause problems for the rest of the team.

While the company is small, a single shared sandbox environment is usually enough. As you grow bigger, you may need 
more to avoid conflicts. The gold standard is to have each developer spin up their own completely isolated environment 
for testing and to tear it down when they are done. Since all of your infrastructure is defined as code, you should be 
able to automate this process!

Once you've figured out where you are going to test, to apply your changes, do the following:

1. Install [Terragrunt](https://github.com/gruntwork-io/terragrunt). We use Terragrunt to keep the Terraform code as 
   DRY as possible, so you'll need Terragrunt to make changes. See [Keep your Terraform code 
   DRY](https://github.com/gruntwork-io/terragrunt#keep-your-terraform-code-dry) and [Keep your remote state 
   configuration DRY](https://github.com/gruntwork-io/terragrunt#keep-your-remote-state-configuration-dry) for 
   background info on how we're taking advantage of Terragrunt.

1. Configure your AWS credentials as [environment variables](http://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html).



1. Go into the appropriate folder in infrastructure-live for your sandbox environment.

1. Run `terragrunt plan` to see what impact your changes will have.

1. If the plan looks good, run `terragrunt apply` to deploy those changes. 

Note: if you've made changes in infrastructure-modules, use the `--terragrunt-source` parameter to point
Terragrunt at your local checkout of infrastructure-modules. E.g., if you checked out 
infrastructure-modules to `~/source/infrastructure-modules`, then you can test your changes
locally, without creating a new release of infrastructure-modules, by running
`terragrunt plan --terragrunt-source ~/source/infrastructure-modules/my-module` and
`terragrunt apply --terragrunt-source ~/source/infrastructure-modules/my-module`.

Note: you can also create *automated* tests for your modules using the 
[Terratest](https://github.com/gruntwork-io/terratest) library. Check out the `test` folder in any Gruntwork module
for examples, such as the [module-ecs tests](https://github.com/gruntwork-io/module-ecs/tree/master/test) and 
[module-asg tests](https://github.com/gruntwork-io/module-asg/tree/master/test).


### Submit a pull request

Once your code is working in the sandbox environment:

* Commit your changes to a new branch

* Submit a pull request so other team members can review your code.

* If you only made changes in the sandbox environment in infrastructure-live, then your pull request 
  should include analogous changes in all the other environments in infrastructure-live (but, of course, 
  don't apply those changes yet!). 
  
* If you made changes in infrastructure-modules, then submit the pull request in that repo first. After
  that pull request has been merged and a new version released, you can submit a pull request (or multiple pull 
  requests) in infrastructure-live updating all environments to use the new version. All of this is 
  described in the next few sections.


### Merge in your changes

If the code looks good, merge your changes into the master branch. The basic idea is that master should always reflect
what's deployed in prod, so the next step is to deploy the code!


### Release a new version

If your code changes included a change to infrastructure-modules, you should release a new version by 
creating a new Git tag. If you use GitHub, you can do this by creating a new release on the releases page. 
Alternatively, you can do it with the Git CLI:

```bash
git tag -a v0.0.2 -m "added module foo"
git push --follow-tags
```


### Promote the new version to prod

You can now begin deploying this new, immutable version of your infrastructure through all of your environments:
e.g, qa -> stage -> prod. There are two ways to do this:
   
1. You can submit a single pull request in infrastructure-live to update all the environments. Once its
   merged, you can run `terragrunt plan` and `terragrunt apply` in each environment to deploy the changes.

1. If you need to test the changes in each environment before deploying to the next environment, you may want to do a
   separate pull request for each environment, and merge and deploy them one at a time.

 


## Next steps

Now that your code is built, tested, and deployed, it's time to take a look at [Monitoring, Alerting, and 
Logging](06-monitoring-alerting-logging.md).
