/*
# define the GCP authentication file
variable "gcp_auth_file" {
  type = string
  description = "GCP authentication file"
}
*/

# define GCP project name
variable "project_id" {
  type = string
  description = "GCP project name"
}

# define GCP APP name
variable "app_name" {
  type = string
  description = "Deploy App name"
}

# define GCP region
variable "region" {
  type = string
  description = "GCP region"
}
# define GCP zone
variable "zone" {
  type = string
  description = "GCP zone"
}

# define initial_node_count
variable "initial_node_count" {
  type = string
  description = "initial_node_count"
}
# define node_count
variable "node_count" {
  type = string
  description = "node_count"
}
# define min_node_count
variable "min_node_count" {
  type = string
  description = "min_node_count"
}
# define max_node_count
variable "max_node_count" {
  type = string
  description = "max_node_count"
}

# define ip subnet
variable "ip_cidr_range" {
  type = string
  description = "ip_cidr_range"
}
variable "ip_cluster_range" {
  type = string
  description = "ip_cluster_range"
}

# define kubernetes deployment
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