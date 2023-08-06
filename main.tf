
terraform {
  required_version = ">= 1.0.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.12.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.2.1"
  project_id                  = var.project_id
  activate_apis = [
  "iap.googleapis.com","iam.googleapis.com","privateca.googleapis.com",
  "cloudresourcemanager.googleapis.com","sqladmin.googleapis.com",
  "container.googleapis.com","autoscaling.googleapis.com",
  "compute.googleapis.com","servicenetworking.googleapis.com",
  "identitytoolkit.googleapis.com",
  ]
  disable_services_on_destroy = false
}
provider "tls" {}

provider "docker" {
  registry_auth {
    address  = "gcr.io"
    username = "oauth2accesstoken"
    password = "${data.google_client_config.default.access_token}"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
resource "google_service_account" "default" {
  account_id   = "service"
  display_name = "Terraform Service Account"
  disabled     = false
  project = var.project_id
}
resource "google_project_iam_member" "sa_iam" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.default.email}"
    lifecycle {
    create_before_destroy = true
  }
}
resource "google_project_iam_member" "sa_container_iam" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.default.email}"
    lifecycle {
    create_before_destroy = true
  }
}
resource "google_project_iam_member" "sa_cloudsql_iam" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.default.email}"
      lifecycle {
    create_before_destroy = true
  }
}

data "google_client_config" "default" {
}
provider "kubernetes" {
  host                   = "https://${google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(google_container_cluster.cluster.master_auth[0].client_certificate)
  client_key             = base64decode(google_container_cluster.cluster.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)

}

resource "null_resource" "nullremote1" {
  depends_on = [google_container_cluster.cluster,google_container_node_pool.node_pool]
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --zone ${google_container_cluster.cluster.location} --project ${google_container_cluster.cluster.project}"
    }
}

resource "null_resource" "set_gcloud_project" {
  provisioner "local-exec" {
    command = "gcloud config set project ${var.project_id}"
  }  
}


#  ssl_certificate #
resource "google_compute_managed_ssl_certificate" "cert" {
  name        = "oday-cert3"
  description = "SSL certificate for ${var.domain_name}"
  managed {
    domains = [var.domain_name]
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "google_compute_global_address" "default" {
   name          = "global-ip1"
   address_type  = "EXTERNAL"
}

