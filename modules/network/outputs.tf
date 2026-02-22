# modules/network/outputs.tf

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc_network.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc_network.id
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = google_compute_subnetwork.subnet.id
}