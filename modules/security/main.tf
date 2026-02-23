# modules/security/main.tf

# ==============================================================================
# INTERVIEW TALKING POINTS (Enterprise Patterns)
# ------------------------------------------------------------------------------
# 1. Centralized Secrets: We use Secret Manager instead of passing API keys via
#    environment variables in plaintext or checking them into source control.
# 2. Strict IAM Binding: We bind the specific Secret Assessor role to the 
#    Cloud Run service account *only* for this specific secret. Even if the
#    service account escapes its container, it cannot read other secrets in the project.
# ==============================================================================

# Ensure Secret Manager API is enabled
resource "google_project_service" "secretmanager" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Define the Secret Metadata
resource "google_secret_manager_secret" "api_key" {
  secret_id = "${var.env_name}-inference-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

# Define the Secret Payload (Version 1)
# Note: In a real enterprise, Terraform might only create the metadata (above), 
# and the actual payload is injected out-of-band by a security team. For this lab, 
# we are pushing a dummy payload to prove the plumbing works.
resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = var.api_key_payload
}

# IAM Binding: Allow the Cloud Run Service Account to read this specific secret
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  project   = google_secret_manager_secret.api_key.project
  secret_id = google_secret_manager_secret.api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.compute_service_account_email}"
}