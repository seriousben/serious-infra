# projects.seriousben.com Terraform project

This terraform project provisions a kubenetes cluster (GKE) in Google Cloud Platform.

It uses traefik as a the proxy of the cluster.

## Deploy

1. `terraform plan`
1. `terraform apply`

## Details

These scripts will:

1. Create a GCP Network
1. Create a GCP Subnet with a custom CIDR
1. Create a managed DNS Zone
1. Create a GKE Cluster in the network / subnet
1. Create a frontend proxy for the kubernetes cluster (Traefik)
1. Create a DNS Alias Record at the root of the zone pointing to the Proxy
