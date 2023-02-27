terraform {
  backend "remote" {
    organization = "digital-nomad-school"

    workspaces {
      name = "dns-mlp-lab"
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

resource "digitalocean_project" "mlp" {
  name        = "mlp"
  description = "Minimal Lovable Product"
  purpose     = "Digital Nomad School project kickoff"
  environment = "Development"
}

resource "digitalocean_vpc" "k8s-vpc" {
  name   = "k8s-vpc"
  region = "fra1"

  timeouts {
    delete = "4m"
  }
}

data "digitalocean_kubernetes_versions" "prefix" {
    version_prefix = "1.25."
}

resource "digitalocean_kubernetes_cluster" "mlp" {
    name = "mlp"
    region = "fra1"
    auto_upgrade = true
    version = data.digitalocean_kubernetes_versions.prefix.latest_version

    vpc_uuid = digitalocean_vpc.k8s-vpc.id

    maintenance_policy {
      start_time = "4:00"
      day = "sunday"
    }

    node_pool {
      name = "worker-pool"
      size = "s-2vcpu-2gb"
      node_count = 2
    }
}