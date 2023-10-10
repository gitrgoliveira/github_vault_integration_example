#!/bin/bash -l
echo "******************************************************************"
echo "* Script to setup challenge                                      *"
echo "******************************************************************"
echo
echo
echo "Please enter your GitHub user ID."
read GITHUB_OWNER
echo
echo "Please enter your GitHub personal access token."
read -s GITHUB_TOKEN
echo
echo "Please enter your HCP Vault address."
read VAULT_ADDR
echo
echo "Please enter your HCP Vault admin token."
read -s VAULT_TOKEN
echo
echo "GitHub User ID : $GITHUB_OWNER"
# echo "GitHub Personal Access Token : $GITHUB_TOKEN"
echo "HCP Vault hostname : $VAULT_ADDR"
# echo "HCP Vault token : $VAULT_TOKEN"
echo
read -p "Do these look right to you? Y/n " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Please try again."
  exit 1
fi
echo

export GITHUB_TOKEN=$GITHUB_TOKEN
export GITHUB_OWNER=$GITHUB_OWNER
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$VAULT_TOKEN

cat >> terraform.tfvars <<EOM
github_org="$GITHUB_OWNER"
vault_address="$VAULT_ADDR"
EOM
