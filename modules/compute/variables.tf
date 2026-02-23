# modules/compute/variables.tf

variable "project_id" { type = string }
variable "region" { type = string }
variable "env_name" { type = string }

variable "vpc_id" {
  description = "The ID of the VPC to attach the Cloud Run service to."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the Subnet to attach the Cloud Run service to."
  type        = string
}

variable "container_image" {
  description = "The container image to deploy (default: hello-world for bootstrap)"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cpu_limit" {
  description = "CPU allocation for the container"
  type        = string
  default     = "1000m" # 1 vCPU
}

variable "memory_limit" {
  description = "Memory allocation for the container"
  type        = string
  default     = "512Mi" # 512 MB
}