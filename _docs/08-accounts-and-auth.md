# Accounts and Auth

In the last section, you learned about connecting to your servers using [SSH and VPN](07-ssh-vpn.md). In this section,
you'll learn about connecting to your AWS accounts:

* [Auth basics](#auth-basics)
* [Account setup](#account-setup)
* [Authenticating](#authenticating)



## Auth basics

For an overview of AWS authentication, including how to authenticate on the command-line, we **strongly** recommend
reading [A Comprehensive Guide to Authenticating to AWS on the Command
Line](https://blog.gruntwork.io/a-comprehensive-guide-to-authenticating-to-aws-on-the-command-line-63656a686799).




## Account setup

Each of your environments (e.g., stage, prod) is in a separate AWS account. This gives you more fine grained control 
over who can access what and improves isolation and security, as a mistake or breach in one account is unlikely to 
affect the others. The accounts are:

* **dev**: `805321607950` 
* **prod**: `608056288583` 
* **security**: `296216577101` 
* **shared-services**: `451511469926` 
* **stage**: `645769240473` 


Note that all IAM users are deployed in a single account called "Security." The idea is that you log into the Security 
account and, if you need to do something in one of the other accounts, you "switch" to it by assuming an IAM Role in
that account (if you've been granted the necessary permissions).

* [Switching accounts prerequisites](#switching-accounts-prerequisites)
* [Switching accounts in the AWS console](#switching-accounts-in-the-aws-console)
* [Switching accounts with CLI tools](#switching-accounts-with-cli-tools)


### Switching accounts prerequisites

If you are logged in as an IAM user in account A and you want to switch to account B, you need the following:

1. Account B must have an IAM role that explicitly allows your IAM user in account A (or all IAM users in account A)
   to assume that IAM role. We have already set this up in all accounts using the [cross-account-iam-roles 
   module](https://github.com/gruntwork-io/module-security/tree/master/modules/cross-account-iam-roles).

1. Your IAM user in account A must have the proper IAM permissions to assume roles in account B. We have created IAM
   groups with these permissions using the [iam-groups 
   module](https://github.com/gruntwork-io/module-security/tree/master/modules/iam-groups). Typically, these IAM groups
   using the naming convention `_account.xxx`, where `xxx` is the name of an account you can switch to (e.g. 
   `_account.stage`, `_account.prod`). There is also an `_account.all` group that allows you to switch to all other 
   accounts. Make sure your IAM user is in the appropriate group.
   
Once you take care of the two prerequisites above, you will need two pieces of information to switch to another 
account:

1. The ID of the account you wish to switch to. You should get this from whoever administers your AWS accounts.

1. The name of the IAM role in that account you want to assume. Typically, this will be one of the [roles from the
   cross-account-iam-roles module](https://github.com/gruntwork-io/module-security/tree/master/modules/cross-account-iam-roles#resources-created),
   such as `allow-read-only-access-from-other-accounts` or `allow-full-access-from-other-accounts`.

With these two pieces of data, you should be able to switch accounts in the AWS console or with AWS CLI tools as 
explained in the following two sections.


### Switching accounts in the AWS console

Check out the [AWS Switching to a Role (AWS Console)
documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html) for instructions
on how to switch between accounts in the AWS console with a single click.


### Switching with CLI tools (including Terraform)

The official way to assume an IAM role with AWS CLI tools is documented here: [AWS Switching to a Role (AWS Command 
Line Interface) documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-cli.html). This
process requires quite a few steps, so here are easier ways to do it:

1. [Terragrunt](https://github.com/gruntwork-io/terragrunt) has the ability to assume an IAM role before running 
   Terraform. That means you can authenticate to any account by:
   
    1. Authenticate to your Security account (the one where the IAM users are defined) using the normal process, such 
       as setting the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables for that account.
    
    1. Call Terragrunt with the `--terragrunt-iam-role` argument or set the `TERRAGRUNT_IAM_ROLE` environment variable.
        For example, to assume the `allow-full-access-from-other-accounts` role in account `1111111111111`: 
       `export TERRAGRUNT_IAM_ROLE=arn:aws:iam::1111111111111:role/allow-full-access-from-other-accounts`.
    
    1. Now you can use all your normal Terragrunt commands: e.g., `terragrunt plan`.    

1. If you want to assume an IAM role in another account for some other AWS CLI tool, the easiest way to do it is with
   the [aws-auth script](https://github.com/gruntwork-io/module-security/tree/master/modules/aws-auth), which can
   reduce the authentication process to a one-liner. This tool is also useful for authenticating in the CLI when MFA
   is enabled.




## Authenticating

Some best practices around authenticating to your AWS account:

* [Enable MFA](#enable-mfa)
* [Use a password manager](#use-a-password-manager)
* [Don't use the root user](#dont-user-the-root-user)

Note that most of this section comes from the [Gruntwork Security Best Practices 
document](https://docs.google.com/document/d/e/2PACX-1vTikva7hXPd2h1SSglJWhlW8W6qhMlZUxl0qQ9rUJ0OX22CQNeM-91w4lStRk9u2zQIn6lPejUbe-dl/pub), so make sure to read through that for more info.

### Enable MFA

Always enable multi-factor authentication (MFA) for your AWS account. That is, in addition to a password, you must
provide a second factor to prove your identity. The best option for AWS is to install [Google
Authenticator](https://support.google.com/accounts/answer/1066447?hl=en) on your phone and use it to generate a one-time
token as your second factor.


### Use a password manager

Never store secrets in plain text. Store your secrets using a secure password manager, such as 
[pass](https://www.passwordstore.org/), [OS X Keychain](https://en.wikipedia.org/wiki/Keychain_(software)), or
[KeePass](http://keepass.info/). You can also use cloud-based password managers, such as 
[1Password](https://1password.com/) or [LastPass](https://www.lastpass.com/), but be aware that since they have 
everyone's passwords, they are inherently much more tempting targets for attackers. That said, any reasonable password
manager is better than none at all!


### Don't use the root user

AWS uses the [Identity and Access Management (IAM)](https://aws.amazon.com/iam/) service to manage users and their 
permissions. When you first sign up for an AWS account, you are logged in as the *root user*. This user has permissions 
to do everything in the account, so if you compromise these credentials, you’re in deep trouble. 

Therefore, right after signing up, you should:

1. Enable MFA on your root account. Note: we strongly recommend making a copy of the MFA secret key. This way, if you 
   lose your MFA device (e.g. your iPhone), you don’t lose access to your AWS account. To make the backup, when 
   activating MFA, AWS will show you a QR code. Click the "show secret key for manual configuration" link and save that 
   key to a secure password manager. 

1. Make sure you use a very long and secure password. Never share that password with anyone. If you need to store it 
   (as opposed to memorizing it), only store it in a secure password manager.
    
1. Use the root account to create a separate IAM user for yourself and your team members with more limited IAM 
   permissions. You should manage permissions using IAM groups. See the [iam-groups 
   module](https://github.com/gruntwork-io/module-security/tree/master/modules/iam-groups) for details.

1. Use IAM roles when you need to give limited permissions to tools (for eg, CI servers or EC2 instances).

1. Require all IAM users in your account to use MFA.

1. Never use the root IAM account again.










## Next steps

Now that you know how to authenticate, you may want to take a look through this list of [Gruntwork
Tools](09-gruntwork-tools.md).
