# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform IAM Wrapper Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-iam/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-iam.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-iam.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-iam/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for IAM simplifies the configuration of IAM roles, OIDC providers, and service users in the AWS cloud. This wrapper functions as a predefined template, facilitating the creation and management of IAM resources by handling all the technical details.

### ✨ Features

- 🔐 [GitHub OIDC Integration](#github-oidc-integration) - Create IAM roles with GitHub Actions OIDC authentication for secure CI/CD workflows

- 📝 [Advanced Inline Policies](#advanced-inline-policies) - Create fine-grained permissions with custom inline policies

- 🔑 [Service IAM User](#service-iam-user) - Create an IAM user with an access key for an external system that cannot assume a role



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-iam" target="_blank">terraform-aws-modules/iam/aws</a> | 6.4.0 |



## 🚀 Quick Start
```hcl
iam_parameters = {
  oidc_provider = {
    github = {
      url = "https://token.actions.githubusercontent.com"
    }
  }
  role = {
    github = {
      enable_github_oidc = true
      oidc_subjects = [
        "repo:your-org/your-repo:pull_request",
        "repo:your-org/your-repo:ref:refs/heads/main"
      ]
      policies = {
        S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      }
    }
  }
}

iam_defaults = var.iam_defaults
```


## 🔧 Additional Features Usage

### GitHub OIDC Integration
Configure IAM roles that can be assumed by GitHub Actions workflows using OIDC (OpenID Connect) authentication. This eliminates the need to store long-lived AWS credentials as secrets in GitHub, providing a more secure and scalable solution for CI/CD pipelines.


<details><summary>Basic GitHub OIDC Role</summary>

```hcl
iam_parameters = {
  oidc_provider = {
    github = {
      url = "https://token.actions.githubusercontent.com"
    }
  }
  role = {
    github = {
      enable_github_oidc = true
      oidc_subjects = [
        "repo:your-org/your-repo:pull_request",
        "repo:your-org/your-repo:ref:refs/heads/main"
      ]
      policies = {
        S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      }
    }
  }
}
```


</details>

<details><summary>Advanced GitHub OIDC with Inline Policies</summary>

```hcl
iam_parameters = {
  oidc_provider = {
    github = {
      url = "https://token.actions.githubusercontent.com"
    }
  }
  role = {
    github = {
      enable_github_oidc = true
      oidc_subjects = [
        "repo:your-org/your-repo:pull_request",
        "repo:your-org/your-repo:ref:refs/heads/main",
        "repo:your-org/your-repo:ref:refs/heads/development"
      ]
      policies = {
        S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      }
      create_inline_policy = true
      inline_policy_permissions = {
        "ecr" = {
          effect = "Allow"
          actions = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:PutImage"
          ]
          resources = [
            "arn:aws:ecr:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${local.common_name}*"
          ]
        }
        "ecs" = {
          effect = "Allow"
          actions = [
            "ecs:DescribeTaskDefinition",
            "ecs:RegisterTaskDefinition",
            "ecs:UpdateService",
            "ecs:DescribeServices"
          ]
          resources = ["*"]
        }
        "lambda" = {
          effect = "Allow"
          actions = [
            "lambda:GetFunction",
            "lambda:UpdateFunctionCode",
            "lambda:InvokeFunction"
          ]
          resources = [
            "arn:aws:lambda:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:function:*${local.common_name}*"
          ]
        }
        "passrole" = {
          effect = "Allow"
          actions = ["iam:PassRole"]
          resources = ["*"]
          condition = [
            {
              test     = "StringEqualsIfExists"
              variable = "iam:PassedToService"
              values = [
                "ec2.amazonaws.com",
                "ecs-tasks.amazonaws.com",
                "events.amazonaws.com"
              ]
            }
          ]
        }
        "s3" = {
          effect = "Allow"
          resources = [
            "arn:aws:s3:::${local.common_name}*"
          ]
          actions = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:DeleteObject",
            "s3:ListBucket"
          ]
        }
      }
    }
  }
}
```


</details>


### Advanced Inline Policies
Define custom inline policies with granular permissions, conditions, and resource restrictions. This allows for precise access control beyond what managed policies provide.


<details><summary>Inline Policy with Conditions</summary>

```hcl
iam_parameters = {
  role = {
    advanced = {
      create_inline_policy = true
      inline_policy_permissions = {
        "s3-conditional" = {
          effect = "Allow"
          actions = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          resources = [
            "arn:aws:s3:::my-bucket/*"
          ]
          condition = [
            {
              test     = "StringEquals"
              variable = "s3:x-amz-server-side-encryption"
              values   = ["AES256"]
            }
          ]
        }
        "time-based" = {
          effect = "Allow"
          actions = ["s3:ListBucket"]
          resources = ["arn:aws:s3:::my-bucket"]
          condition = [
            {
              test     = "DateGreaterThan"
              variable = "aws:CurrentTime"
              values   = ["2024-01-01T00:00:00Z"]
            }
          ]
        }
      }
    }
  }
}
```


</details>


### Service IAM User
Create a service IAM user without console access and attach an inline policy for a single integration, such as pushing images to ECR. When `create_ssm_parameters` is enabled, the access key ID and secret are stored together as JSON in one SSM Parameter Store SecureString. The secret remains in the Terraform state.


<details><summary>ECR Push User</summary>

```hcl
iam_parameters = {
  user = {
    ecr_vendor = {
      create_login_profile   = false
      create_access_key      = true
      create_ssm_parameters  = true
      create_inline_policy   = true
      inline_policy_permissions = {
        "ecr-auth" = {
          effect = "Allow"
          actions = [
            "ecr:GetAuthorizationToken"
          ]
          resources = ["*"]
        }
        "ecr-push" = {
          effect = "Allow"
          actions = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage"
          ]
          resources = [
            "arn:aws:ecr:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${local.common_name}*"
          ]
        }
      }
    }
  }
}
```


</details>




## 📑 Inputs
| Name                                  | Description                                                                                 | Type           | Default                                         | Required |
| ------------------------------------- | ------------------------------------------------------------------------------------------- | -------------- | ----------------------------------------------- | -------- |
| role.create                           | Controls if resources should be created                                                     | `bool`         | `true`                                          | no       |
| role.name                             | Name to use on IAM role created                                                             | `string`       | `"${local.common_name}-${each.key}"`            | no       |
| role.use_name_prefix                  | Determines whether the IAM role name is used as a prefix                                    | `bool`         | `true`                                          | no       |
| role.path                             | Path of IAM role                                                                            | `string`       | `null`                                          | no       |
| role.description                      | Description of the role                                                                     | `string`       | `null`                                          | no       |
| role.max_session_duration             | Maximum session duration (in seconds) for the role                                          | `number`       | `null`                                          | no       |
| role.permissions_boundary             | ARN of the policy used to set the permissions boundary                                      | `string`       | `null`                                          | no       |
| role.trust_policy_permissions         | A map of IAM policy statements for custom trust policy permissions                          | `map(object)`  | `null`                                          | no       |
| role.trust_policy_conditions          | Condition constraints applied to the trust policy(s)                                        | `list(object)` | `[]`                                            | no       |
| role.policies                         | Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format               | `map(string)`  | `{}`                                            | no       |
| role.enable_oidc                      | Enable OIDC provider trust for the role                                                     | `bool`         | `false`                                         | no       |
| role.oidc_account_id                  | Overriding AWS account ID where the OIDC provider lives                                     | `string`       | `null`                                          | no       |
| role.oidc_provider_urls               | List of URLs of the OIDC Providers                                                          | `list(string)` | `[]`                                            | no       |
| role.oidc_subjects                    | The fully qualified OIDC subjects to be added to the role policy                            | `list(string)` | `[]`                                            | no       |
| role.oidc_wildcard_subjects           | The OIDC subject using wildcards to be added to the role policy                             | `list(string)` | `[]`                                            | no       |
| role.oidc_audiences                   | The audience to be added to the role policy                                                 | `list(string)` | `[]`                                            | no       |
| role.enable_github_oidc               | Enable GitHub OIDC provider trust for the role                                              | `bool`         | `false`                                         | no       |
| role.github_provider                  | The GitHub OIDC provider URL without the `https://` prefix                                  | `string`       | `"token.actions.githubusercontent.com"`         | no       |
| role.enable_bitbucket_oidc            | Enable Bitbucket OIDC provider trust for the role                                           | `bool`         | `false`                                         | no       |
| role.enable_saml                      | Enable SAML provider trust for the role                                                     | `bool`         | `false`                                         | no       |
| role.saml_provider_ids                | List of SAML provider IDs                                                                   | `list(string)` | `[]`                                            | no       |
| role.saml_endpoints                   | List of AWS SAML endpoints                                                                  | `list(string)` | `["https://signin.aws.amazon.com/saml"]`        | no       |
| role.saml_trust_actions               | Additional assume role trust actions for the SAML federated statement                       | `list(string)` | `[]`                                            | no       |
| role.create_inline_policy             | Determines whether to create an inline policy                                               | `bool`         | `false`                                         | no       |
| role.source_inline_policy_documents   | List of IAM policy documents that are merged together                                       | `list(string)` | `[]`                                            | no       |
| role.override_inline_policy_documents | List of IAM policy documents that override existing statements                              | `list(string)` | `[]`                                            | no       |
| role.inline_policy_permissions        | A map of IAM policy statements for inline policy permissions                                | `map(object)`  | `null`                                          | no       |
| role.create_instance_profile          | Determines whether to create an instance profile                                            | `bool`         | `false`                                         | no       |
| role.tags                             | A map of tags to add to all resources                                                       | `map(string)`  | `{}`                                            | no       |
| oidc_provider.create                  | Controls if resources should be created                                                     | `bool`         | `true`                                          | no       |
| oidc_provider.url                     | The URL of the identity provider. Corresponds to the iss claim                              | `string`       | `"https://token.actions.githubusercontent.com"` | no       |
| oidc_provider.client_id_list          | List of client IDs (also known as audiences) for the IAM OIDC provider                      | `list(string)` | `[]`                                            | no       |
| oidc_provider.tags                    | A map of tags to add to the resources created                                               | `map(any)`     | `{}`                                            | no       |
| user.create                           | Controls if the IAM user should be created                                                  | `bool`         | `true`                                          | no       |
| user.name                             | Name of the IAM user                                                                        | `string`       | `"${local.common_name}-${each.key}"`            | no       |
| user.path                             | Path of the IAM user                                                                        | `string`       | `null`                                          | no       |
| user.permissions_boundary             | ARN of the policy used to set the permissions boundary                                      | `string`       | `null`                                          | no       |
| user.force_destroy                    | Destroy the user even when it has non-Terraform-managed keys, login profile, or MFA devices | `bool`         | `false`                                         | no       |
| user.policies                         | Policies to attach to the IAM user in `{'static_name' = 'policy_arn'}` format               | `map(string)`  | `{}`                                            | no       |
| user.create_login_profile             | Whether to create an IAM user login profile                                                 | `bool`         | `false`                                         | no       |
| user.pgp_key                          | PGP key used to encrypt the password and the access key secret                              | `string`       | `null`                                          | no       |
| user.password_length                  | Length of the generated console password                                                    | `number`       | `null`                                          | no       |
| user.password_reset_required          | Whether the user must reset the generated password on first login                           | `bool`         | `true`                                          | no       |
| user.create_access_key                | Whether to create an IAM access key                                                         | `bool`         | `true`                                          | no       |
| user.access_key_status                | Access key status to apply                                                                  | `string`       | `null`                                          | no       |
| user.create_ssh_key                   | Whether to upload a public SSH key to the IAM user                                          | `bool`         | `false`                                         | no       |
| user.ssh_key_encoding                 | Public key encoding format (`SSH` or `PEM`)                                                 | `string`       | `"SSH"`                                         | no       |
| user.ssh_public_key                   | SSH public key encoded in ssh-rsa or PEM format                                             | `string`       | `""`                                            | no       |
| user.create_inline_policy             | Whether to create an inline policy                                                          | `bool`         | `false`                                         | no       |
| user.source_inline_policy_documents   | List of IAM policy documents that are merged together                                       | `list(string)` | `[]`                                            | no       |
| user.override_inline_policy_documents | List of IAM policy documents that override existing statements                              | `list(string)` | `[]`                                            | no       |
| user.inline_policy_permissions        | A map of IAM policy statements for inline policy permissions                                | `map(object)`  | `null`                                          | no       |
| user.create_ssm_parameters            | Store the access key ID and secret as JSON in one SSM SecureString                          | `bool`         | `false`                                         | no       |
| user.ssm_parameter_prefix             | Prefix for the SSM parameter name                                                           | `string`       | `"/${local.common_name}/${each.key}"`           | no       |
| user.ssm_kms_key_id                   | KMS key ID used to encrypt the access key secret parameter                                  | `string`       | `null`                                          | no       |
| user.tags                             | A map of tags to add to the user and the SSM parameter                                      | `map(string)`  | `{}`                                            | no       |







## ⚠️ Important Notes
- **🔐 Security Best Practice:** Always use the principle of least privilege when configuring IAM roles and policies.
- **⚠️ OIDC Subjects:** Be specific with OIDC subjects to restrict access to only the necessary repositories, branches, or workflows.
- **ℹ️ Permissions Boundary:** Use `permissions_boundary` to set an upper limit on permissions that a role can have.
- **🔄 Session Duration:** Configure `max_session_duration` appropriately based on your security requirements (1-12 hours).
- **🔒 Access Key Secret:** The IAM access key secret is stored in Terraform state. SSM Parameter Store is an additional copy, not a replacement.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 