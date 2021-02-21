provider "google" {
    project = var.project
    region = "us-central1"
}

module "apolloio_gke_cluster" {
    source = "../modules/gke_zonal_cluster"

    cluster_name = "apolloio"
}
