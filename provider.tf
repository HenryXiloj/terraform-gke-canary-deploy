terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.18.0"
    }

  }

  /* backend "gcs" {
    bucket      = "GCS bucket"
    prefix      = "terraform/state"
  }*/
}

provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
