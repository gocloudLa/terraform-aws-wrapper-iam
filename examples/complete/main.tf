module "wrapper_iam" {
  source = "../../"

  metadata = local.metadata

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
          "repo:gocloudLa/lab-aws-oidc:pull_request",
          "repo:gocloudLa/lab-aws-oidc:ref:refs/heads/main",
          "repo:gocloudLa/lab-aws-oidc:ref:refs/heads/development",
        ]
        policies = {
          S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
        }

        create_inline_policy = true
        inline_policy_permissions = {
          "ecrauth" = {
            effect = "Allow"
            actions = [
              "ecr:GetAuthorizationToken"
            ]
            resources = [
              "*"
            ]
          }
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
              "ecr:GetLifecyclePolicy",
              "ecr:GetLifecyclePolicyPreview",
              "ecr:ListTagsForResource",
              "ecr:DescribeImageScanFindings",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload",
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
            resources = [
              "*"
            ]
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
            actions = [
              "iam:PassRole"
            ]
            resources = [
              "*"
            ]
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
          "events" = {
            effect = "Allow"
            actions = [
              "events:ListTargetsByRule",
              "events:PutTargets"
            ]
            resources = [
              "arn:aws:events:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${local.common_name}*"
            ]
          }
          "cloudfront" = {
            effect = "Allow"
            actions = [
              "cloudfront:ListDistributions",
              "cloudfront:CreateInvalidation"
            ]
            resources = [
              "*"
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
              "s3:GetBucketAcl",
              "s3:GetBucketLocation",
              "s3:ListBucket"
            ]
          }
        }
      }
    }

    # Service user for an on-prem pipeline that can only consume long-lived keys.
    # Console login stays off. The access key secret stays in Terraform state and is copied to SSM.
    user = {
      ecr_vendor = {
        # create            = true   # Default: true
        # name              = null   # Default: ${local.common_name}-<key>
        # path              = "/"    # Default: null
        # force_destroy     = false  # Default: false
        # permissions_boundary = "arn:aws:iam::123456789012:policy/resource-01xxxxxxxxxxxxx"

        create_login_profile = false # Default in upstream module: true
        # pgp_key               = null  # Encrypts the access key (and the password, if login is on)
        # password_length       = 20
        # password_reset_required = true

        create_access_key = true # Default: true
        # access_key_status = "Active" # Active | Inactive

        create_ssm_parameters = true # Default: false
        # ssm_parameter_prefix = "/${local.common_name}/ecr_vendor" # Default: /${local.common_name}/<key>
        # ssm_kms_key_id       = null # Default: null (aws/ssm)

        # create_ssh_key    = false
        # ssh_key_encoding  = "SSH" # SSH | PEM
        # ssh_public_key    = "ssh-rsa AAAA..."

        policies = {
          # Optional managed policy. ECR push below is the inline policy.
          # ECRReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        }

        create_inline_policy = true
        # source_inline_policy_documents   = []
        # override_inline_policy_documents = []
        inline_policy_permissions = {
          "ecr-auth" = {
            sid    = "EcrAuth"
            effect = "Allow"
            actions = [
              "ecr:GetAuthorizationToken"
            ]
            resources = ["*"]
          }
          "ecr-push" = {
            sid    = "EcrPush"
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
            condition = [
              {
                test     = "StringEquals"
                variable = "aws:RequestedRegion"
                values   = [local.metadata.aws_region]
              }
            ]
          }
          "ecr-deny-delete" = {
            sid    = "EcrDenyDelete"
            effect = "Deny"
            actions = [
              "ecr:DeleteRepository",
              "ecr:BatchDeleteImage"
            ]
            resources = [
              "arn:aws:ecr:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${local.common_name}*"
            ]
          }
        }

        # tags = {} # Merged with local.common_tags
      }
    }
  }

  iam_defaults = var.iam_defaults
}