# modules/loadbalancer/main.tf

# ==============================================================================
# INTERVIEW TALKING POINTS (Enterprise Patterns)
# ------------------------------------------------------------------------------
# 1. Edge Security & Performance: Placing a Global HTTP(S) Load Balancer in 
#    front of Cloud Run gives us a single static anycast IP, enabling Cloud CDN 
#    caching, Cloud Armor WAF rules, and multi-region routing if we expand.
# 2. Serverless NEG: The Serverless Network Endpoint Group (NEG) is the critical
#    bridge. It allows the VPC-native load balancer to target the serverless
#    Cloud Run service directly, without exposing the service to the internet.
# 3. HTTPS & Managed Certs: In a true production environment, we use 
#    google_compute_managed_ssl_certificate and google_compute_target_https_proxy.
#    Since GCP Managed Certs require DNS verification, we deploy HTTP for the lab
#    but have the HTTPS architecture documented below.
# ==============================================================================

# Reserve a static external IP address for the Load Balancer
resource "google_compute_global_address" "lb_ip" {
  name    = "${var.env_name}-inference-lb-ip"
  project = var.project_id
}

# The Serverless NEG pointing to the Cloud Run service
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "${var.env_name}-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id

  cloud_run {
    service = var.cloud_run_service_name
  }
}

# The Backend Service
resource "google_compute_backend_service" "backend" {
  name        = "${var.env_name}-inference-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  project     = var.project_id

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# The URL Map (routes all traffic to our single backend service)
resource "google_compute_url_map" "url_map" {
  name            = "${var.env_name}-url-map"
  default_service = google_compute_backend_service.backend.id
  project         = var.project_id
}

# ------------------------------------------------------------------------------
# HTTP PROXY (Lab Mode)
# ------------------------------------------------------------------------------
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.env_name}-http-proxy"
  url_map = google_compute_url_map.url_map.id
  project = var.project_id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "${var.env_name}-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.id
  project    = var.project_id
}

# ------------------------------------------------------------------------------
# HTTPS PROXY (Production Enterprise Pattern)
# Uncomment these blocks and provide a domain name to enable SSL termination at the Edge.
# GCP will automatically provision and renew the SSL certificate once DNS is pointed to the LB IP.
# ------------------------------------------------------------------------------

# resource "google_compute_managed_ssl_certificate" "default" {
#   name    = "${var.env_name}-managed-cert"
#   project = var.project_id
#
#   managed {
#     domains = [var.domain_name]
#   }
# }

# resource "google_compute_target_https_proxy" "https_proxy" {
#   name             = "${var.env_name}-https-proxy"
#   url_map          = google_compute_url_map.url_map.id
#   ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
#   project          = var.project_id
# }

# resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
#   name       = "${var.env_name}-https-forwarding-rule"
#   target     = google_compute_target_https_proxy.https_proxy.id
#   port_range = "443"
#   ip_address = google_compute_global_address.lb_ip.id
#   project    = var.project_id
# }