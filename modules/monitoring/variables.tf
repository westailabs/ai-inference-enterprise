# modules/monitoring/variables.tf

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "env_name" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service to monitor"
  type        = string
}

variable "alert_email" {
  description = "The email address to send monitoring alerts to"
  type        = string
}