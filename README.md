# deploy Wordpress on GKE 
## Run 

Initialize the terraform by executing:

    Terraform init

See what will build by executing:

    Terraform plan

Apply the config by executing:

    Terraform apply

## Task steps
 1. creating SQL Database and user for this DB (SQL.tf)
 2. Docker file for installing Apache, PHP, and WordPress and use it for creating the Image and pushing it using Terraform.(GKE.tf file)
 and use the image = "gcr.io/${var.project_id}/${var.app_name}:${var.wordpress_version}" in Deployment.

 3. Creating service type: NodePort(GKE.tf), creating managed_ssl_certificate (main. tf), Creating ingress, and adding annotations to use the certificate and force SSL redirect.

 4. Enable IAP for WordPress website by adding annotations in the Ingress section

    <img width="563" alt="Screenshot 2023-08-05 195442" src="https://github.com/odaymahamid2211/WordpressOnGKE/assets/126683590/b97dabcc-afa1-4e90-bded-17c7b27a9e26">

 


