terraform {
  required_version = ">=1.6.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3"
    }

    github = {
      source  = "integrations/github"
      version = ">= 5"
    }
  }

}