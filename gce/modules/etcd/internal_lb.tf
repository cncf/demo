resource "google_compute_forwarding_rule" "default" {
  name       = "${ var.name }"
  load_balancing_scheme = "INTERNAL"
  ip_address = "${ var.internal_lb }"
  region     = "${ var.region }"
  ports      = ["8080"]
  network    = "${ var.network }"
  subnetwork = "${ var.subnetwork }"
  backend_service     = "${ google_compute_region_backend_service.cncf.self_link }"
}
