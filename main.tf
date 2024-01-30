# provider "kubernetes" {
#   config_path    = "~/.kube/config" # chemin vers le fichier de configuration de Kubernetes
#   config_context = "microservices" # le contexte utilisé pour les charges de travail à déployer
#     }
#   terraform {
#    required_providers {
#            kubernetes = {
#                  source  = "hashicorp/kubernetes"
#                        version = "~> 2.9.0"
#                         }
#                       }
#             }


locals {
 datacientest-wordpress = {
   App = "datacientest-wordpress"
   Tier = "frontend"
 }
 datacientest-mysql = {
   App = "datacientest-wordpress"
   Tier = "mysql"
 }
}
resource "kubernetes_secret" "datascientest-mysql-password" {
 metadata {
   name = "datascientest-mysql-password"
 }
 data = {
   password = "Datascientest123@" # le mot de passe aura pour valeur Datascientest123@
 }
}

resource "kubernetes_deployment" "datacientest-wordpress" {
 metadata {
   name = "datacientest-wordpress"
   labels = local.datacientest-wordpress  # récupère les valeurs déclarées dans la variable datacientest-wordpress
 }
 spec {
   replicas = 1  # nombre de réplicas
   selector {
     match_labels = local.datacientest-wordpress
   }
   template {
     metadata {
       labels = local.datacientest-wordpress
     }
     spec {
       container {
         image = "wordpress:4.8-apache" # image à utiliser pour le déploiement de wordpress
         name  = "datacientest-wordpress"
         port {
           container_port = 80
         }
         env {  # déclaration des variables d'environnement
           name = "WORDPRESS_DB_HOST"
           value = "mysql-service"
         }
         env {
           name = "WORDPRESS_DB_PASSWORD"
           value_from {
             secret_key_ref {
               name = "datascientest-mysql-password"
               key = "password"
             }
           }
         }
       }
     }
   }
 }
}

resource "kubernetes_service" "wordpress-service" {
 metadata {
   name = "wordpress-service"
 }
 spec {
   selector = local.datacientest-wordpress # récupère les valeurs déclarées dans la variable datacientest-wordpress afin de renvoyer les requêtes sur les bons pods
   port {
     port        = 80 # Port ouvert, on parle ici d'un service web qui écoute le port 80
     target_port = 80 # Port cible
     node_port = 32000 # port ouvert sur chaque noeud
   }
   type = "NodePort" # type de service NodePort qui permettra un accès depuis chaque noeud du cluster sur le port 32000
 }
}

resource "kubernetes_deployment" "mysql" {
 metadata {
   name = "mysql"
   labels = local.datacientest-mysql # récupère les valeurs déclarées dans la variable datacientest-mysql
 }
 spec {
   replicas = 1
   selector {
     match_labels = local.datacientest-mysql
   }
   template {
     metadata {
       labels = local.datacientest-mysql
     }
     spec {
       container {
         image = "mysql:5.6" # image à utiliser pour le déploiement de mysql
         name  = "mysql"
         port {
           container_port = 3306
         }
         env {
           name = "MYSQL_ROOT_PASSWORD" # déclaration de la valeur de MYSQL_ROOT_PASSWORD à récupérer depuis le secret mysql-pass
           value_from {
             secret_key_ref {
               name = "datascientest-mysql-password"
               key = "password"
             }
           }
         }
       }
     }
   }
 }
}

resource "kubernetes_service" "mysql-service" {
 metadata {
   name = "mysql-service"
 }
 spec {
   selector = local.datacientest-mysql
   port {
     port        = 3306
     target_port = 3306
   }
   type = "NodePort"
 }
}