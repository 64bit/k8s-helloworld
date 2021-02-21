terraform {
  backend "gcs" {
    bucket  = "apolloio-terraform-state"
    prefix  = "apolloio"
  }
}
