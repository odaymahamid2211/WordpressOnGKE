
# GCP Settings
project_id = "wideops-avishay"
region = "me-west1"
zone = "me-west1-a"

# GCP Network VPC
ip_cidr_range  = "10.15.5.0/24"
ip_cluster_range = "10.79.240.0/20"


# container cluster
initial_node_count="2"
node_count="2"
min_node_count="1"
max_node_count="3"
replicas="1"

app_name ="wordpress"

db_user="oday"
db_password="2211"
db_name="my-database"



# ssl #
domain_name = "oday.ddns.net"
cluster_name = "my-cluster"

wordpress_version = "1.5"
