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
  }

  iam_defaults = var.iam_defaults
}