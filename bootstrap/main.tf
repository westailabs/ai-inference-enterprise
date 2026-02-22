# bootstrap/main.tf
# This configuration creates the Google Cloud Storage bucket that will hold
# the remote state for all other environments (dev, staging, prod).

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# The remote state bucket
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-tfstate" # Must be globally unique
  location      = var.region
  force_destroy = false # Prevent accidental deletion of the state bucket

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5 # Retain only the last 5 state versions
    }
  }
}