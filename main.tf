

# GITHUB_TOKEN
provider "github" {
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
    oidc_discovery_url = "https://token.actions.githubusercontent.com"
    bound_issuer = "https://token.actions.githubusercontent.com"
}

resource "vault_jwt_auth_backend_role" "github" {
    backend = vault_jwt_auth_backend.github.path
    role_type = "jwt"
    role_name = "github_jwt"
    bound_audiences = [ "https://github.com/${var.github_org}" ]
    user_claim = "sub"
    bound_claims_type = "glob"

    bound_claims = {
      "sub" = "repo:${var.github_repo}/*",
      "environment" = "*",
      "repository" = "*",
    }
    
}