output "iam_user_arns" {
  description = "ARN of each IAM user"
  value       = { for k, m in module.iam_user : k => m.arn }
}

output "iam_user_names" {
  description = "Name of each IAM user"
  value       = { for k, m in module.iam_user : k => m.name }
}

output "iam_user_access_key_ids" {
  description = "Access key ID of each IAM user"
  value       = { for k, m in module.iam_user : k => m.access_key_id }
}

output "iam_user_ssm_access_key_parameter_names" {
  description = "SSM parameter name holding each IAM user access key as JSON"
  value = {
    for k, m in module.iam_user : k => try(aws_ssm_parameter.iam_user_access_key[k].name, null)
  }
}
