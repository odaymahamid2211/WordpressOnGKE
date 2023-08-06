

variable "initial_node_count" {
  type = string
  description = "initial_node_count"
}

variable "node_count" {
  type = string
  description = "node_count"
}

variable "min_node_count" {
  type = string
  description = "min_node_count"
}

variable "max_node_count" {
  type = string
  description = "max_node_count"
}
variable "project_id" {
  type = string
  description = "GCP project name"
}


variable "app_name" {
  type = string
  description = "Deploy App name"
}


variable "region" {
  type = string
  description = "GCP region"
}

variable "zone" {
  type = string
  description = "GCP zone"
}

variable "domain_name" {
  type = string
  description = "domain_name"
}

variable "cluster_name" {
  type = string
  description = "cluster_name"
}

variable "wordpress_version" {
  type = string
}

variable "ip_cidr_range" {
  type = string
  description = "ip_cidr_range"
}

variable "ip_cluster_range" {
  type = string
  description = "ip_cluster_range"
}

variable "replicas" {
  type = string
  description = "replicas"
}

variable "db_user" {
  type = string
  description = "db_user"
}
variable "db_password" {
  type = string
  description = "db_password"
}
variable "db_name" {
  type = string
  description = "db_name"
}

