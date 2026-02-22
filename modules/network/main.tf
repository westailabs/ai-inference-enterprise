# modules/network/main.tf

# ==============================================================================
# INTERVIEW TALKING POINTS (Enterprise Patterns)
# ------------------------------------------------------------------------------
# 1. Modularity: In our previous lab, everything was flattened in the root. 
#    Here, the network is isolated as a reusable module. This allows 'dev', 
#    'staging', and 'prod' environments to stamp out identical topologies 
#    without duplicating code.
# 2. Parameterization: Note the use of `${var.env_name}`. This prevents naming 
#    collisions if multiple environments are deployed in the same GCP project.
# 3. Explicit Dependencies: We explicitly depend on the Compute API being enabled
#    before trying to build the VPC.
# ==============================================================================

# Ensure the Compute API is enabled for the project before building networking
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# The Virtual Private Cloud (VPC)
# Auto-create is disabled because enterprise environments demand explicit subnet 
# definition for strict IP address management (IPAM) and firewall zoning.
resource "google_compute_network" "vpc_network" {
  name                    = "${var.env_name}-ai-inference-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id

  depends_on = [google_project_service.compute]
}

# The Subnet for our resources
# The CIDR range is parameterized so different environments don't overlap,
# which is critical if we ever peer these VPCs together in the future.
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.env_name}-ai-inference-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}