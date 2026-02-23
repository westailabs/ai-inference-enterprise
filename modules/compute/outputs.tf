# modules/compute/outputs.tf

output "cloud_run_service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_v2_service.inference_api.name
}

output "cloud_run_service_id" {
  description = "The ID of the Cloud Run service"
  value       = google_cloud_run_v2_service.inference_api.id
}

output "cloud_run_service_url" {
  description = "The URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.inference_api.uri
}

output "service_account_email" {
  description = "The email of the dedicated service account"
  value       = google_service_account.inference_sa.email
}