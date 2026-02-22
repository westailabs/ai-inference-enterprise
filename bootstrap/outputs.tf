# bootstrap/outputs.tf

output "state_bucket_name" {
  description = "The name of the GCS bucket created for remote state."
  value       = google_storage_bucket.terraform_state.name
}