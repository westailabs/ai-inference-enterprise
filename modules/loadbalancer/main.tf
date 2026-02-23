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
# 3. Encapsulation: Notice this module only knows about 'cloud_run_service_name'.
#    It doesn't care how the compute was built or what network it's on; it just 
#    routes traffic to the provided target.
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

# The HTTP Proxy (routing traffic from the forwarding rule to the URL map)
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.env_name}-http-proxy"
  url_map = google_compute_url_map.url_map.id
  project = var.project_id
}

# The Global Forwarding Rule (listening on port 80 and routing to the proxy)
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "${var.env_name}-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.id
  project    = var.project_id
}