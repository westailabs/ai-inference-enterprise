# modules/security/variables.tf

variable "project_id" { type = string }
variable "env_name" { type = string }

variable "compute_service_account_email" {
  description = "The email of the Cloud Run service account that needs access to the secret."
  type        = string
}

variable "api_key_payload" {
  description = "The actual string value of the API key or secret."
  type        = string
  sensitive   = true # Prevent Terraform from printing this value in console output logs
}