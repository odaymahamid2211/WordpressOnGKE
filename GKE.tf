
#   kubernetes - GKE    #

resource "google_container_cluster" "cluster" {
  project = var.project_id
  name = var.cluster_name
  location = var.zone
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool = true
  initial_node_count = var.initial_node_count
  network    = "default"
  subnetwork = "default"
  node_config {
    machine_type = "e2-micro"
    metadata = {
    disable-legacy-endpoints = "true"
    }
    preemptible = true
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
resource "google_container_node_pool" "node_pool" {
  name       = "node-pool"
  cluster    = google_container_cluster.cluster.name
  location = var.zone
  node_count = var.node_count
  node_config {
    preemptible  = true
    machine_type = "e2-micro"
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  depends_on = [google_container_cluster.cluster]

}


 resource "null_resource" "docker_build" {
   triggers = {
   always_run = timestamp()
   }
  provisioner "local-exec" {
   command     = "gcloud builds submit --tag gcr.io/${var.project_id}/${var.app_name}:${var.wordpress_version}"
   }
 }


# Deployment #

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = var.app_name
  }
  spec {
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    replicas = var.replicas
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      spec {
        container {
          name  = "wordpress"
          image = "gcr.io/${var.project_id}/${var.app_name}:${var.wordpress_version}"
          env {
            name  = "DB_HOST"
            value = "${google_sql_database_instance.instance.ip_address.0.ip_address}"
          }
          env {
            name  = "DB_USER"
            value = var.db_user
          }
          env {
            name  = "DB_PASSWORD"
            value = var.db_password
          }
          env {
            name  = "DB_NAME"
            value = var.db_name
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
    depends_on = [
    google_container_cluster.cluster,
    google_container_node_pool.node_pool,
  ]
}



  #  service #



resource "kubernetes_service_v1" "wordpress" {
  metadata {
    name = "service-wp1"
    #annotations = {
      #"cloud.google.com/backend-config" = "{\"ports\": {\"80\":\"http-hc-config\"}}"
      #"cloud.google.com/neg" = "{\"ingress\": true}"
    #}
  }
  spec {
    selector ="${kubernetes_deployment.wordpress.spec.0.template.0.metadata.0.labels}"
    # type           = "LoadBalancer"
    #external_traffic_policy = "Cluster"
    session_affinity = "ClientIP"
    type           = "NodePort"
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
      node_port = 32155
    }
  }
  depends_on = [google_container_cluster.cluster,kubernetes_deployment.wordpress,]
}




# ingress #



resource "kubernetes_ingress_v1" "wordpress" {
  metadata {
    name = "ingress-wp1"
    annotations = {
      "kubernetes.io/ingress.class" = "gce"
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.default.name
      "kubernetes.io/ingress.allow-http"          = "false"
      "ingress.gcp.kubernetes.io/pre-shared-cert"   = google_compute_managed_ssl_certificate.cert.name
       "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
       "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
       "nginx.ingress.kubernetes.io/ssl-redirect"  = "true"
       #"cloud.google.com/backend-config" = "http-hc-config"
       "nginx.ingress.kubernetes.io/from-to-www-redirect" = "true"
       "nginx.ingress.kubernetes.io/rewrite-target" = "/"
       "iap.ingress.kubernetes.io/enabled" = "true"
       "nginx.ingress.kubernetes.io/configuration-snippet" = <<EOF
        location /wp-login.php {
            auth_request /iap;
            auth_request_set $cookie_iap_tunnel $upstream_http_set_cookie;
            iap_tunnel_cookie_policy all;
                }
        EOF
    }
  } 
    spec {
     rule {
      host = "${var.domain_name}"
      http {
        path {
          path = "/wp-admin/*"
          backend {
            service {
              name = kubernetes_service_v1.wordpress.metadata[0].name
              port {
                number = kubernetes_service_v1.wordpress.spec[0].port[0].port
                }
              }
          }
        }
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service_v1.wordpress.metadata[0].name
              port {
                number = kubernetes_service_v1.wordpress.spec[0].port[0].port
                }
              }
          }
        }
      }
    }
  }
}
