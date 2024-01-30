terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.6.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # chemin du fichier de configuration kubernetes
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}