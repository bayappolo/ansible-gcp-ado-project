# Terraform Providers Configuration for RHAA Enterprise GCP Deployment

terraform {
  required_providers {
    google {
      source = "hashicorp/google"
      
      version = "~> 5.0"
      
      configuration {
        # Retry settings for API calls
        retry_timeout = "1h"
        retry_condition = "response == not(2xx)"
        
        # User project override (for billing)
        user_project_override = var.user_project_override
        
        # Access token authentication
        access_token = var.gcp_access_token
        
        application_default {
          credentials_file = var.gcp_credentials_path
          scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
          ]
        }
      }
    }
    
    google-beta {
      source = "hashicorp/google"
      
      version = "~> 5.0"
    }
    
    random {
      source = "hashicorp/random"
      
      version = "~> 3.1"
    }
    
    null {
      source = "hashicorp/null"
      
      version = "~> 3.1"
    }
    
    time {
      source = "hashicorp/time"
      
      version = "~> 0.9"
    }
    
    tls {
      source = "hashicorp/tls"
      
      version = "~> 4.0"
    }
  }
}

# Provider aliases for multi-cloud scenarios (future use)
provider "aws" {
  alias = "primary"
  
  region                      = var.aws_region
  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Local providers for testing
provider "local" {
  source = "hashicorp/local"
  
  version = "~> 2.0"
}
