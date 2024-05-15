#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

PROJECT_ID="[PROJECT_ID]"

REPO_OWNER="[REPO_OWNER]"
REPO_NAME="[REPO_NAME]"

SA_ROLE="roles/bigquery.dataEditor"
SA_NAME="bq-data-editor-sa"
SA_DISPLAY_NAME="BigQuery Data Editor Service Account"
SA_DESCRIPTION="Service account responsible for creating BigQuery datasets and tables"

SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

POOL_NAME="github-actions-pool"
POOL_DISPLAY_NAME="GitHub Actions Pool"
PROVIDER_NAME="github-repo-provider"
PROVIDER_DISPLAY_NAME="GitHub Repo Provider"
ISSUER_URI="https://token.actions.githubusercontent.com"


echo "Set the default project:"
gcloud config set project "$PROJECT_ID"

echo "Enable necessary services:"
gcloud services enable iamcredentials.googleapis.com
# services specific to the project's tasks
gcloud services enable bigquery.googleapis.com

echo "Create the service account:"
gcloud iam service-accounts create "$SA_NAME" \
  --display-name="$SA_DISPLAY_NAME" \
  --description="$SA_DESCRIPTION"

echo "Bind the service account to the role:"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SA_EMAIL" \
  --role="$SA_ROLE"

echo "Create the workload identity pool:"
gcloud iam workload-identity-pools create "$POOL_NAME" \
  --project="$PROJECT_ID" \
  --location="global" \
  --display-name="$POOL_DISPLAY_NAME"

echo "Get the pool ID:"
POOL_ID=$(gcloud iam workload-identity-pools describe "$POOL_NAME" \
  --project="$PROJECT_ID" \
  --location="global" \
  --format="value(name)")

echo "Create the OIDC provider:"
gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_NAME" \
  --project="$PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_NAME" \
  --display-name="$PROVIDER_DISPLAY_NAME" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository_owner == '$REPO_OWNER'" \
  --issuer-uri="$ISSUER_URI"

echo "Bind the service account to the workload identity pool:"
gcloud iam service-accounts add-iam-policy-binding "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --project="$PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/$POOL_ID/attribute.repository/$REPO_OWNER/$REPO_NAME"

echo "Get the provider ID:"
PROVIDER_ID=$(gcloud iam workload-identity-pools providers describe "$PROVIDER_NAME" \
  --project="$PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_NAME" \
  --format="value(name)")

echo "OIDC Provider ID: $PROVIDER_ID"
echo "Service Account Email: $SA_EMAIL"
