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

variable "pagerduty_service_key" {
  description = "The PagerDuty service/integration key for alerts"
  type        = string
  sensitive   = true
}