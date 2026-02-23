# modules/compute/main.tf

# ==============================================================================
# INTERVIEW TALKING POINTS (Enterprise Patterns)
# ------------------------------------------------------------------------------
# 1. Service Accounts (Least Privilege): We create a dedicated Service Account 
#    strictly for this Cloud Run service. It does not use the default Compute 
#    Engine service account (which has Editor privileges and is a huge security risk).
# 2. Immutable Infrastructure: Cloud Run is serverless. We define the container 
#    image, limits, and concurrency here. When the image updates, Terraform 
#    deploys a new immutable revision.
# 3. Network Isolation: We are attaching the Cloud Run service to the custom VPC
#    using Direct VPC Egress, keeping its outbound traffic off the public internet.
# ==============================================================================

# Dedicated Identity for the AI Inference Service
resource "google_service_account" "inference_sa" {
  account_id   = "${var.env_name}-inference-sa"
  display_name = "Service Account for ${var.env_name} AI Inference Cloud Run"
  project      = var.project_id
}

# The Cloud Run Service (V2)
resource "google_cloud_run_v2_service" "inference_api" {
  name     = "${var.env_name}-ai-inference-api"
  location = var.region
  project  = var.project_id
  
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" # Only allow traffic from our LB

  template {
    service_account = google_service_account.inference_sa.email
    
    containers {
      image = var.container_image
      
      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
      
      ports {
        container_port = 8080
      }
    }

    # Direct VPC Egress to route traffic through our custom subnet
    vpc_access {
      network_interfaces {
        network    = var.vpc_id
        subnetwork = var.subnet_id
      }
      egress = "ALL_TRAFFIC"
    }
  }
}

# Allow unauthenticated invocations (the Load Balancer will handle access control/WAF)
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.inference_api.location
  project  = google_cloud_run_v2_service.inference_api.project
  service  = google_cloud_run_v2_service.inference_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}