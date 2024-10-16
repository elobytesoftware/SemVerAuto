# Automated Releases and Deployment Workflow Documentation

This document details the GitHub Actions workflow for automating releases, versioning, and deployments using secrets from HashiCorp Vault. The workflow is triggered on specific branches and handles changelog generation, and deployment to different environments accordingly.

## Workflow Triggers

The workflow is activated on pushes to the following branches:

- `main`
- `releases/prod/* (for production environment)`
- `releases/qa/* (for QA environment)`

## Job

### Steps

1. **Generate Changelog**
   - Uses: `TriPSs/conventional-changelog-action@v5`
   - Inputs:
     - `github-token`: `${{ secrets.GITHUB_TOKEN }}`
   - Generates a changelog based on conventional commits.

2. **Create Release**
   - Uses: `actions/create-release@v1`
   - Runs if the changelog generation was successful.
   - Inputs:
     - `tag_name`: `${{ steps.changelog.outputs.tag }}`
     - `release_name`: `${{ steps.changelog.outputs.tag }}`
     - `body`: `${{ steps.changelog.outputs.clean_changelog }}`
   - Creates a GitHub release.

3. **Retrieve Secrets from Vault**
   - Uses: `hashicorp/vault-action@v2`
   - Runs if a release is created.
   - Inputs:
     - `url`: `${{ secrets.VAULT_ADDR }}`
     - `method`: `"token"`
     - `token`: `${{ secrets.VAULT_TOKEN }}`
     - `secrets`: Retrieves multiple secrets including Docker credentials and deployment hooks.

4. **Use the Retrieved Secrets**
   - Runs a script to display the retrieved Docker username and password (for verification).

5. **Log in to Docker Hub (if needed)**
   - Uses Docker credentials to log in via CLI.

6. **Trigger Deployment**
    - Uses cURL to POST to deployment hooks based on the branch.
    - Conditions:
      - `main` branch: Uses `MAIN_DEPLOY_HOOK`.
      - `releases/qa/*` branch: Uses `QA_DEPLOY_HOOK`.
      - `releases/prod/*` branch: Uses `PROD_DEPLOY_HOOK`.

## Notes

- **Conventional Commits**: 
- **Vault Integration**: Secrets are securely retrieved from HashiCorp Vault. Ensure Vault URL and token are correctly set in GitHub Secrets.
- **Deployment**: Deployment hooks are triggered based on the branch. Each environment (main, QA, prod) has its own hook.


## Troubleshooting

- **Failed Changelog**: Check that commits follow the conventional format.
- **Vault Access Issues**: Verify Vault URL and token.

