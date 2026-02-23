# environments/dev/main.tf
# Dev Environment Configuration

# ==============================================================================
# INTERVIEW TALKING POINTS (Enterprise Patterns)
# ------------------------------------------------------------------------------
# 1. State Management: The 'backend "gcs"' block moves state files out of git
#    and local disks into a Google Cloud Storage bucket.
# 2. State Locking: GCS backend automatically handles state locking via the
#    GCP Storage API to prevent concurrency issues when multiple engineers
#    run 'terraform apply' simultaneously.
# 3. Environment Scaling: By instantiating the 'module "network"' block, we
#    tell Terraform to pull the generic module code, inject our 'dev' parameters
#    (from terraform.tfvars), and deploy the resources. A 'prod' directory
#    would look almost identical but use different parameters.
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  # Enterprise Pattern: Remote state with state locking
  backend "gcs" {
    bucket = "ai-engineering-lab-tfstate"
    prefix = "terraform/state/dev"
  }

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

# The Network Module
# This block instantiates the reusable network module defined in our root
# 'modules/' directory, passing our environment-specific variables down into it.
module "network" {
  source      = "../../modules/network"
  project_id  = var.project_id
  region      = var.region
  env_name    = var.env_name
  subnet_cidr = "10.0.1.0/24" # Example overriding default for Dev
}

# The Compute Module
# Passes the vpc_id and subnet_id outputs from the network module into the compute module
module "compute" {
  source     = "../../modules/compute"
  project_id = var.project_id
  region     = var.region
  env_name   = var.env_name
  vpc_id     = module.network.vpc_id
  subnet_id  = module.network.subnet_id
}
