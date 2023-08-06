# firewall
resource "google_compute_firewall" "wordpress-firewall" {
  name    = "wordpress-firewall"
  network = "default"
  project = var.project_id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80","443","22"]
  }

  source_tags = ["WP"]
  source_ranges = ["0.0.0.0/0"]
}
