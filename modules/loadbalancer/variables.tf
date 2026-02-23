# modules/loadbalancer/variables.tf

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the NEG to"
  type        = string
}

variable "env_name" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service to target with the Serverless NEG"
  type        = string
}