module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.3"

  for_each = var.iam_parameters.role

  create                           = try(each.value.create, var.iam_defaults.role.create, true)
  name                             = try(each.value.name, var.iam_defaults.role.name, "${local.common_name}-${each.key}")
  create_inline_policy             = try(each.value.create_inline_policy, var.iam_defaults.role.create_inline_policy, false)
  create_instance_profile          = try(each.value.create_instance_profile, var.iam_defaults.role.create_instance_profile, false)
  description                      = try(each.value.description, var.iam_defaults.role.description, null)
  enable_bitbucket_oidc            = try(each.value.enable_bitbucket_oidc, var.iam_defaults.role.enable_bitbucket_oidc, false)
  enable_github_oidc               = try(each.value.enable_github_oidc, var.iam_defaults.role.enable_github_oidc, false)
  enable_oidc                      = try(each.value.enable_oidc, var.iam_defaults.role.enable_oidc, false)
  enable_saml                      = try(each.value.enable_saml, var.iam_defaults.role.enable_saml, false)
  github_provider                  = try(each.value.github_provider, var.iam_defaults.role.github_provider, "token.actions.githubusercontent.com")
  inline_policy_permissions        = try(each.value.inline_policy_permissions, var.iam_defaults.role.inline_policy_permissions, null)
  max_session_duration             = try(each.value.max_session_duration, var.iam_defaults.role.max_session_duration, null)
  oidc_account_id                  = try(each.value.oidc_account_id, var.iam_defaults.role.oidc_account_id, null)
  oidc_audiences                   = try(each.value.oidc_audiences, var.iam_defaults.role.oidc_audiences, [])
  oidc_provider_urls               = try(each.value.oidc_provider_urls, var.iam_defaults.role.oidc_provider_urls, [])
  oidc_subjects                    = try(each.value.oidc_subjects, var.iam_defaults.role.oidc_subjects, [])
  oidc_wildcard_subjects           = try(each.value.oidc_wildcard_subjects, var.iam_defaults.role.oidc_wildcard_subjects, [])
  override_inline_policy_documents = try(each.value.override_inline_policy_documents, var.iam_defaults.role.override_inline_policy_documents, [])
  path                             = try(each.value.path, var.iam_defaults.role.path, null)
  permissions_boundary             = try(each.value.permissions_boundary, var.iam_defaults.role.permissions_boundary, null)
  policies                         = try(each.value.policies, var.iam_defaults.role.policies, {})
  saml_endpoints                   = try(each.value.saml_endpoints, var.iam_defaults.role.saml_endpoints, ["https://signin.aws.amazon.com/saml"])
  saml_provider_ids                = try(each.value.saml_provider_ids, var.iam_defaults.role.saml_provider_ids, [])
  saml_trust_actions               = try(each.value.saml_trust_actions, var.iam_defaults.role.saml_trust_actions, [])
  source_inline_policy_documents   = try(each.value.source_inline_policy_documents, var.iam_defaults.role.source_inline_policy_documents, [])
  trust_policy_conditions          = try(each.value.trust_policy_conditions, var.iam_defaults.role.trust_policy_conditions, [])
  trust_policy_permissions         = try(each.value.trust_policy_permissions, var.iam_defaults.role.trust_policy_permissions, null)
  use_name_prefix                  = try(each.value.use_name_prefix, var.iam_defaults.role.use_name_prefix, false)

  tags = merge(local.common_tags, try(each.value.tags, var.iam_defaults.role.tags, null))
}

module "iam_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  version = "6.2.3"

  for_each = var.iam_parameters.oidc_provider

  client_id_list = try(each.value.client_id_list, var.iam_defaults.oidc_provider.client_id_list, [])
  create         = try(each.value.create, var.iam_defaults.oidc_provider.create, true)
  url            = try(each.value.url, var.iam_defaults.oidc_provider.url, "https://token.actions.githubusercontent.com")

  tags = merge(local.common_tags, try(each.value.tags, var.iam_defaults.oidc_provider.tags, null))
}