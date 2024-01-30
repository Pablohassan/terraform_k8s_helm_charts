terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.9.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # chemin du fichier de configuration kubernetes
}