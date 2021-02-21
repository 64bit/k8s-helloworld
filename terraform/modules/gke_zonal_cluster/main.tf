
resource "google_project_service" "main" {
  service = "container.googleapis.com"
  disable_on_destroy =  false
}

resource "google_service_account" "main" {
  account_id = "sa-${var.cluster_name}"
  description = "Service Account for ${var.cluster_name}"
}

resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.zone

  min_master_version = var.min_master_version

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  addons_config {
      horizontal_pod_autoscaling {
        disabled = false
      }

      http_load_balancing {
        disabled = false
      }
  }

  depends_on = [
    google_project_service.main
  ]
}

resource "google_container_node_pool" "main" {
  name       = var.cluster_name
  location   = var.zone
  cluster    = google_container_cluster.main.name

  autoscaling {
      min_node_count = 1
      max_node_count = var.max_node_count
  }

  management {
      auto_repair = true
      auto_upgrade = true
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.main.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  depends_on = [
    google_project_service.main
  ]
}
