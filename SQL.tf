##########################
#                        #
#      DATABASE          #
#
#########################
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
  project =  var.project_id
  depends_on = [
    google_sql_database_instance.instance
  ]
}
resource "google_sql_database_instance" "instance" {
  name     = "db-wordpress-instance"
  database_version = "MYSQL_8_0"
  region   = var.region
  project = var.project_id
  deletion_protection = false
  settings {
    tier = "db-f1-micro"
    activation_policy = "ALWAYS"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name = "public network"
        value = "0.0.0.0/0"
        }
    }
    }

  depends_on = [google_container_cluster.cluster]
}
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = var.db_password
  depends_on = [
  google_sql_database_instance.instance
    ]
}
