# bootstrap/variables.tf

variable "project_id" {
  description = "The GCP project ID where the state bucket will reside."
  type        = string
}

variable "region" {
  description = "The GCP region for the state bucket."
  type        = string
  default     = "us-central1"
}