# GitHub Actions with GCP using Workload Identity Federation

This repository provides a foundational template for local development and continuous integration/continuous deployment (CI/CD) using GitHub Actions to securely interact with Google Cloud Platform (GCP) resources via Workload Identity Federation (WIF). This setup enables GitHub Actions to authenticate directly with GCP services, eliminating the need for managing private keys or persistent service account credentials. The Workload Identity Pool used in this template impersonates a Google Cloud Service Account which has the necessary IAM permissions on GCP resources. This configuration not only enhances security but also allows the same service account to be used locally, thereby increasing the maintainability of development operations. This template is ideal for both local development environments and automated deployment workflows.

## Project Structure

- `interact_with_gcp_resources.sh`: Bash script that facilitates interaction with GCP resources, suitable for both local development and CI/CD pipelines, maintaining consistency across environments.
- `setup_github_actions_wif.sh`: This script automates the configuration of Workload Identity Federation on GCP by setting up a workload identity pool, a provider, and a service account. The Workload Identity Pool impersonates the Google Cloud Service Account which has IAM permission on GCP resources.
- `gcp_resource_management_workflow.yml`: The GitHub Actions workflow that is authenticated to GCP using the OIDC provider configured via Workload Identity Federation, enabling automated interaction with GCP resources.

## Prerequisites

Before you begin, ensure you have the [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install) installed.


## Pipeline Setup

This section guides you through setting up a pipeline for automating deployments using Google Cloud Platform (GCP) and GitHub Actions, including the necessary configurations.

1. Create a GCP project and enable billing
2. Set up a Github repository
3. Clone this repository
4. Modify `setup_github_actions_wif.sh` 

    <details>
    <summary>Details</summary>

    Ensure to correctly populate `PROJECT_ID` and the variables related to the repository (`REPO_OWNER`, `REPO_NAME`) and the service account (`SA_ROLE`, `SA_NAME`, `SA_DISPLAY_NAME`, `SA_DESCRIPTION`) that will interact with GCP resources through the GitHub Actions workflow.

    Choose the service account related variables based on the specific tasks your GitHub Actions workflow is designed to perform. Different tasks may require different permissions and roles.

    Additionally, remember to include gcloud commands to enable any necessary services specific to your needs. For example, in the default case it's:

    ```bash
    gcloud services enable bigquery.googleapis.com
    ```

    </details>


5. Run `setup_github_actions_wif.sh`

    <details>
    <summary>Details</summary>

    You can run the script from your local machine or cloud shell to set up the necessary components on GCP for workload identity federation.

    This script will perform the following actions:
    - Enable necessary APIs.
    - Create a new service account.
    - Bind roles to the service account.
    - Create a workload identity pool and provider.
    - Bind the GitHub repository to the service account through the provider.

    </details>
    
6. Populate Github secrets

    <details>
    <summary>Details</summary>

    Add two required github secrets (`SERVICE_ACCOUNT_EMAIL`,`WORKLOAD_IDENTITY_PROVIDER_ID`) using the values printed by `setup_github_actions_wif.sh` script.

    In case you have missed the script output, you can always find the values in the cloud console, or you could run the gcloud command to print those values again.

    </details>

7. Configure workflow triggers

    <details>
    <summary>Details</summary>

    Commented-out trigger configuration is provided as a default setting, which triggers the workflow on a push to the master branch and manual dispatch.

    Uncomment and modify the `on:` section in the workflow file (`gcp_resource_management_workflow.yml`) to suit your triggering requirements.

    More details about included triggers:
    - [workflow_dispatch trigger](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch)

    - [push trigger](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#push)

    </details>

8. Push the cloned and modified content to your newly created repo

9. Run the Workflow

    <details>
    <summary>Details</summary>

    If you left the default trigger configuration, the workflow will run automatically on every push to the master branch. You can also run it manually:

    1. Go to the Actions tab in your repository.
    2. Select the appropriate workflow.
    3. Click the Run workflow button to manually dispatch it.
    
    Manual triggering is possible because the default settings include `workflow_dispatch`.

    </details>

With these steps completed, your pipeline is now set up for automated deployments using GCP and GitHub Actions. This setup will help streamline your deployment processes, enhancing efficiency and reducing the need for manual intervention. Next, consider exploring additional GitHub Actions to further optimize your workflow or integrate additional tools and services into your deployment pipeline.


## Local Environment Setup

To set up your local environment for testing and interaction with GCP resources, follow these steps:

1. Authenticate with Google Cloud:
    ```bash
    gcloud auth login
    ```

2. Create a service account key file:
    ```bash
    gcloud iam service-accounts keys create "[PATH_TO_KEY_FILE]" --iam-account="SERVICE_ACCOUNT_EMAIL"
    ```

3. Authenticate using the newly created service account key file:
    ```bash
    gcloud auth login --cred-file="[PATH_TO_KEY_FILE]"
    ```

4. Set `GOOGLE_APPLICATION_CREDENTIALS` environment variable value to `"[PATH_TO_KEY_FILE]"`

At this point, your local environment is configured to interact with Google Cloud Platform resources using the service account. You are now ready to run commands and manage GCP resources through the service account's permissions.


## Additional Resources

For further information and tutorials on setting up and securing your CI/CD pipelines with GitHub Actions and Google Cloud Platform, consider exploring the following resources:

- [YouTube: How to use Github Actions with Google's Workload Identity Federation](https://www.youtube.com/watch?v=ZgVhU5qvK1M&t) - The video explains the purpose of Workload Identity Federation and provides a walkthrough for configuring it with GitHub Actions using the Cloud Console approach

- [Google GitHub Actions Auth: Setup Guide](https://github.com/google-github-actions/auth?tab=readme-ov-file#setup) - A broader perspective on configuring Workload Identity Federation, including Direct Workload Identity Federation, which bypasses the need for a service account.

- [GitHub Docs: Configuring OpenID Connect in Google Cloud Platform](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform) - More details on how to configure trust link between GCP and Github Actions. Also,`ISSUER_URI` is provided under the link.

- [GitHub Docs: About security hardening with OpenID Connect](https://github.com/google-github-actions/auth?tab=readme-ov-file#setup) - More details on how GitHub uses OpenID Connect (OIDC).


## Contributing

Contributions are welcome! Feel free to open a pull request with any improvements, or raise an issue if you encounter problems.