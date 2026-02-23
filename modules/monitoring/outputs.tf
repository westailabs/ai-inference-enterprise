# modules/monitoring/outputs.tf

output "alert_policy_names" {
  description = "The names of the generated alert policies"
  value = [
    google_monitoring_alert_policy.high_error_rate.name,
    google_monitoring_alert_policy.high_latency.name
  ]
}