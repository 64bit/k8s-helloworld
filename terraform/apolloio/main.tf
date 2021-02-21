provider "google" {
    project = var.project
}

module "apolloio_gke_cluster" {
    source = "../modules/gke_zonal_cluster"

    cluster_name = "apolloio"
}
