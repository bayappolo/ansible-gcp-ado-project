# Monitoring Module for RHAA Enterprise Observability

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google {
      source = "hashicorp/google"
      
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

# Monitoring Dashboard for RHAA Enterprise
resource "google_monitoring_dashboard" "rhaa_dashboard" {
  dashboard {
    title       = "${var.dashboard.title}"
    description = "${var.dashboard.description}"
    
    charts {
      chart_type = var.dashboard.chart_type
      
      timeseries {
        title       = var.dashboard.charts[0].title
        description = "RHAA Enterprise CPU and Memory metrics"
        
        timeseries_query {
          query            = var.dashboard.charts[0].timeseries_filter
          interval         = "30s"
          perSeriesLimit   = 10
          offset           = "0s"
          alignment_region = "INTERVAL"
        }
      }
    }
    
    tabs {
      title       = var.dashboard.tabs[0].title
      description = var.dashboard.tabs[0].description
    }
  }
}

# Alerting policies for RHAA Enterprise
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "${var.alerts[0].name}"
  
  condition {
    display_name = "${var.alerts[0].condition.display_name}"
    
    condition_expression {
      and_operator_type = var.alerts[0].condition.and_operator_type
      
      and_conditions {
        conditions {
          condition {
            name           = "CPU Usage Alert"
            comparator     = var.alerts[0].condition.comparator
            threshold_percent = var.alerts[0].condition.threshold_percent
            
            time_series_filter {
              metric_type = var.alerts[0].condition.metric_type
              resource_type = var.alerts[0].condition.resource_type
              
              label_filters {
                key   = "container_name"
                op    = "="
                values = ["rhaa-enterprise-*"]
              }
            }
            
            duration           = var.alerts[0].condition.duration
            aggregation {
              alignment_period     = var.alerts[0].condition.aggregation.alignment_period
              per_series_aligner   = var.alerts[0].condition.aggregation.per_series_aligner
              cross_series_reducer = var.alerts[0].condition.aggregation.cross_series_reducer
              group_by_fields      = var.alerts[0].condition.aggregation.group_by_fields
            }
          }
        }
      }
    }
  }
  
  notification_channels = [var.alerts[0].notifications[0].channel]
}

# Log-based metrics for RHAA Enterprise
resource "google_monitoring_uptime_check_config" "rhaa_uptime" {
  count   = var.enable_uptime_checks ? 1 : 0
  
  display_name = "${var.uptime_check.display_name}"
  
  test {
    http_test {
      path              = var.uptime_check.path
      validate_ssl_cert = true
      
      headers {
        key   = "User-Agent"
        value = "RHAA-Enterprise-Monitoring/1.0"
      }
      
      expected_response_code = 200
    }
  }
  
  timeout_sec = var.uptime_check.timeout_sec
  
  period_sec = var.uptime_check.period_sec
  
  failure_threshold = var.uptime_check.failure_threshold
  
  max_broken_link_attempts = var.uptime_check.max_broken_link_attempts
  
  enabled = true
  
  monitored_resource {
    type = "uptime_url"
    
    label {
      project_id = var.project_id
    }
    
    label {
      location = var.location
    }
  }
}

output "dashboard_name" {
  value = google_monitoring_dashboard.rhaa_dashboard.name
}
