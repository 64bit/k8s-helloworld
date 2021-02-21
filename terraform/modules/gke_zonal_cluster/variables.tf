variable "cluster_name" {
    description = "Name of the GKE cluster"
}

variable "zone" {
    default = "us-central1-a"
}

variable "preemptible" {
    description = "Node type is preemptible"
    type = bool
    default = true
}

variable "machine_type" {
    default = "n1-standard-1"
}

variable "max_node_count" {
    default = 3
}

variable "min_master_version" {
    default = "1.16"
}

variable "project" {
    type = string
    description = "GCP Project"
    default = "apolloio"
}
