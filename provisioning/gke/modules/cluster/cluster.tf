resource "google_container_cluster" "cncf" {
  name               = "${ var.name }"
  zone               = "${ var.zone }"
  project            = "${ var.project }"
  initial_node_count = "${ var.node_count }"

  additional_zones   = [
    "us-central1-b",
    "us-central1-c",
  ]

  network            = "${ var.network }"
  subnetwork         = "${ var.subnetwork }"
  node_version       = "${ var.node_version }"

  master_auth {
    username         = "${ var.master_user }"
    password         = "${ var.master_password }"
  }

  node_config {
    machine_type     = "${ var.vm_size }"
    oauth_scopes     = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
