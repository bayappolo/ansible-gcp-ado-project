# Secret Manager Module for RHAA Enterprise Credential Management

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
  region  = var.region
}

# Secret versions for RHAA Enterprise credentials
resource "google_secret_manager_secret" "rhaa_password" {
  name      = "${var.secret_names[0]}"
  replication {
    user_managed {
      replicas {
        location     = var.location
        provider     = google
      }
    }
  }
  
  labels = merge(local.common_tags, {
    secret_type = "password"
  })
}

resource "google_secret_manager_secret_version" "rhaa_password" {
  secret      = google_secret_manager_secret.rhaa_password.id
  secret_data = var.secret_values["rhaa_password"]
}

resource "google_secret_manager_secret" "rhaa_db_password" {
  name      = "${var.secret_names[1]}"
  replication {
    user_managed {
      replicas {
        location     = var.location
        provider     = google
      }
    }
  }
  
  labels = merge(local.common_tags, {
    secret_type = "database-password"
  })
}

resource "google_secret_manager_secret_version" "rhaa_db_password" {
  secret      = google_secret_manager_secret.rhaa_db_password.id
  secret_data = var.secret_values["rhaa_db_password"]
}

resource "google_secret_manager_secret" "rhaa_ssh_keys" {
  name      = "${var.secret_names[2]}"
  replication {
    user_managed {
      replicas {
        location     = var.location
        provider     = google
      }
    }
  }
  
  labels = merge(local.common_tags, {
    secret_type = "ssh-keys"
  })
}

resource "google_secret_manager_secret_version" "rhaa_ssh_keys" {
  secret      = google_secret_manager_secret.rhaa_ssh_keys.id
  secret_data = var.secret_values["rhaa_ssh_keys"]
}

resource "google_secret_manager_secret" "rhaa_api_keys" {
  name      = "${var.secret_names[3]}"
  replication {
    user_managed {
      replicas {
        location     = var.location
        provider     = google
      }
    }
  }
  
  labels = merge(local.common_tags, {
    secret_type = "api-keys"
  })
}

resource "google_secret_manager_secret_version" "rhaa_api_keys" {
  secret      = google_secret_manager_secret.rhaa_api_keys.id
  secret_data = var.secret_values["rhaa_api_keys"]
}

resource "google_secret_manager_secret" "rhaa_sso_certs" {
  name      = "${var.secret_names[4]}"
  replication {
    user_managed {
      replicas {
        location     = var.location
        provider     = google
      }
    }
  }
  
  labels = merge(local.common_tags, {
    secret_type = "ssocertificates"
  })
}

resource "google_secret_manager_secret_version" "rhaa_sso_certs" {
  secret      = google_secret_manager_secret.rhaa_sso_certs.id
  secret_data = var.secret_values["rhaa_sso_certs"]
}

output "secrets" {
  value = {
    rhaa_password   = google_secret_manager_secret_version.rhaa_password.secret
    rhaa_db_password = google_secret_manager_secret_version.rhaa_db_password.secret
    rhaa_ssh_keys     = google_secret_manager_secret_version.rhaa_ssh_keys.secret
    rhaa_api_keys     = google_secret_manager_secret_version.rhaa_api_keys.secret
    rhaa_sso_certs    = google_secret_manager_secret_version.rhaa_sso_certs.secret
  }
}
