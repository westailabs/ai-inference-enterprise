# modules/security/outputs.tf

output "secret_id" {
  description = "The ID of the generated secret"
  value       = google_secret_manager_secret.api_key.secret_id
}

output "secret_version_name" {
  description = "The version path of the generated secret"
  value       = google_secret_manager_secret_version.api_key_version.name
}