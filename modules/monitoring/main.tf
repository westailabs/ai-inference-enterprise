# modules/monitoring/main.tf

# ==============================================================================
# INTERVIEW TALKING POINTS (Enterprise Patterns)
# ------------------------------------------------------------------------------
# 1. Proactive Operations: Instead of waiting for users to complain, we 
#    define Cloud Monitoring Alerts as code. If the Cloud Run service errors out
#    frequently or suffers high latency, an incident is created automatically.
# 2. Notification Channels: Alerts require channels. In a real environment, 
#    this would trigger PagerDuty or Slack so on-call engineers are notified.
# 3. Infrastructure as Code Completeness: By keeping monitoring in Terraform, 
#    we guarantee that when a service is deployed, its observability is deployed 
#    with it. We avoid the "blind spot" risk of manual configuration.
# ==============================================================================

# Ensure Cloud Monitoring API is enabled
resource "google_project_service" "monitoring" {
  project            = var.project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

# Define a PagerDuty Notification Channel
resource "google_monitoring_notification_channel" "pagerduty_alert" {
  display_name = "${var.env_name} PagerDuty Alerts"
  type         = "pagerduty"
  project      = var.project_id
  labels = {
    service_key = var.pagerduty_service_key
  }

  depends_on = [google_project_service.monitoring]
}

# Alert Policy: High Error Rate (5XX Responses)
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "${var.env_name} High Error Rate (${var.cloud_run_service_name})"
  project      = var.project_id
  combiner     = "OR"
  
  conditions {
    display_name = "Cloud Run 5XX Errors > 5%"
    condition_threshold {
      # MQL (Monitoring Query Language) query to track 5XX errors from the specific Cloud Run service
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.cloud_run_service_name}\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05
      
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.pagerduty_alert.name
  ]
}

# Alert Policy: High Latency (> 2 Seconds)
resource "google_monitoring_alert_policy" "high_latency" {
  display_name = "${var.env_name} High Latency (${var.cloud_run_service_name})"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Cloud Run Latency > 2s"
    condition_threshold {
      # Latency metric
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.cloud_run_service_name}\" AND metric.type = \"run.googleapis.com/request_latencies\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 2000 # 2000 milliseconds
      
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.pagerduty_alert.name
  ]
}