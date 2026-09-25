# Complete Example 🚀

This example demonstrates the use of a Terraform module to manage AWS IAM roles, OIDC providers, and a service IAM user with an access key for an external ECR push pipeline.

## 🔧 What's Included

### Analysis of Terraform Configuration

#### Main Purpose
The main purpose is to create IAM roles with GitHub OIDC authentication, configure inline policies for CI/CD workflows, and create a service user that can push images to ECR with long-lived credentials.

#### Key Features Demonstrated
- **OIDC Provider**: Creates an OIDC provider for GitHub Actions authentication.
- **IAM Role with GitHub OIDC**: Configures an IAM role that can be assumed by GitHub Actions workflows.
- **Inline Policies**: Defines custom inline policies for ECR, ECS, Lambda, S3, CloudFront, and Events services.
- **AWS Managed Policies**: Attaches AWS managed policies like S3ReadOnlyAccess.
- **Conditional Permissions**: Implements conditional permissions for IAM PassRole with service restrictions.
- **Service IAM User**: Creates a user without console access, with an access key and an ECR push inline policy scoped by region.
- **SSM Parameter**: Stores the access key ID and secret as JSON in one Parameter Store SecureString.

## 🚀 Quick Start

```bash
terraform init
terraform plan
terraform apply
```

## 🔒 Security Notes

⚠️ **Production Considerations**: 
- This example may include configurations that are not suitable for production environments
- Review and customize security settings, access controls, and resource configurations
- Ensure compliance with your organization's security policies
- Consider implementing proper monitoring, logging, and backup strategies

## 📖 Documentation

For detailed module documentation and additional examples, see the main [README.md](../../README.md) file. 