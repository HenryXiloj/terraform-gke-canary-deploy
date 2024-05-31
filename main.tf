resource "google_container_cluster" "primary" {

  depends_on = [google_service_account.gke_service_account]

  name     = "canary-quickstart-cluster"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  deletion_protection      = false
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true

  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      foo = "bar"
    }
    tags = ["foo", "bar"]
  }

  network    = google_compute_network.nw1-vpc.self_link
  subnetwork = google_compute_subnetwork.nw1-subnet1.self_link
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  depends_on = [google_container_cluster.primary,
  google_service_account.gke_service_account]

  name       = "my-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}