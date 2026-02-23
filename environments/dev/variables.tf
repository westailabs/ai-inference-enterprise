# environments/dev/variables.tf
# Dev Environment Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The default GCP region"
  type        = string
  default     = "us-central1"
}

variable "env_name" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

# ------------------------------------------------------------------------------
# SECURITY VARIABLES
# ------------------------------------------------------------------------------
variable "api_key_payload" {
  description = "The secret API key to inject into Secret Manager"
  type        = string
  sensitive   = true
}

# ------------------------------------------------------------------------------
# MONITORING VARIABLES
# ------------------------------------------------------------------------------
variable "alert_email" {
  description = "The email address to send monitoring alerts to"
  type        = string
}
