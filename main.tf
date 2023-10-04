

# GITHUB_TOKEN
provider "github" {
    owner = var.github_org
}

# configure the GitHub repo with the vault address
resource "github_actions_secret" "VAULT_ADDR" {
    repository = var.github_repo
    secret_name = "VAULT_ADDR"
    plaintext_value = var.vault_address
}

provider "vault" {
    address = var.vault_address
    namespace = "admin" # assuming HCP Vault here
}

# configure the Vault provider from terraform variables
resource "vault_jwt_auth_backend" "github" {
    path = "github_jwt"
    oidc_discovery_url = "https://token.actions.githubusercontent.com"
    bound_issuer = "https://token.actions.githubusercontent.com"
}

resource "vault_jwt_auth_backend_role" "github" {
    backend = vault_jwt_auth_backend.github.path
    role_type = "jwt"
    role_name = "example_role"
    
    # bound_audiences = [ "https://github.com/${var.github_org}" ]
    bound_audiences = [ "example_audience" ]
    user_claim = "sub"
    bound_claims_type = "glob"

    bound_claims = {
      "sub" = "repo:${var.github_org}/${var.github_repo}:*",
      "repository" = "*",
    }
    token_policies = [ vault_policy.github_repo_access.name ]
    
}

resource "vault_policy" "github_repo_access" {
    name = "github_repo_access"
    policy = <<EOT
path "secret/data/*" {
  capabilities = ["read"]
}
EOT
    
}