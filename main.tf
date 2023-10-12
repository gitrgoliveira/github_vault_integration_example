provider "github" {
  owner = var.github_org
}

# resource "random_id" "default" {
#   byte_length = 4
# }

# resource "vault_namespace" "instruqt" {
#   path = "demo_${random_id.default.hex}"
# }

# configure the GitHub repo with the vault address
resource "github_actions_secret" "VAULT_ADDR" {
  repository      = var.github_repo
  secret_name     = "VAULT_ADDR"
  plaintext_value = var.vault_address
}

provider "vault" {
  address   = var.vault_address
  namespace = "admin" # assuming HCP Vault here
}

# configure the Vault provider from terraform variables
resource "vault_jwt_auth_backend" "github" {
  path               = "github_jwt"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
}

resource "vault_jwt_auth_backend_role" "github" {
  backend   = vault_jwt_auth_backend.github.path
  role_type = "jwt"
  role_name = "example_role"

  # bound_audiences = [ "https://github.com/${var.github_org}" ]
  bound_audiences   = ["example_audience"]
  user_claim        = "sub"
  bound_claims_type = "glob"

  bound_claims = {
    "sub"        = "repo:${var.github_org}/${var.github_repo}:*",
    "repository" = "*",
  }
  token_policies = [vault_policy.github_repo_access.name]

}

resource "vault_policy" "github_repo_access" {
  name   = "github_repo_access"
  policy = <<EOT
path "secret/data/*" {
  capabilities = ["read"]
}
EOT

}
resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  mount               = vault_mount.kvv2.path
  name                = "sample-secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      first-secret = "Vault is amazing",
      foo          = "bar"
    }
  )
  custom_metadata {
    max_versions = 5
    data = {
      foo = "vault@example.com",
      bar = "12345"
    }
  }
}
