resource "random_password" "db_password" {
  length  = 16
  special = true
  override_special = "!#$%&*()_-+="
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = var.secret_name
  description = "MongoDB database credentials"
}


resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    MONGODB_PASS = random_password.db_password.result
    MONGODB_USER = "root"
    MONGODB_DB = "fruits"
    MONGODB_HOST = "my-mongo-mongodb.db.svc.cluster.local"
    MONGODB_PORT = "27017"


  })
}

resource "helm_release" "mongodb" {
  name             = "my-mongo"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "mongodb"
  namespace        = "db"
  version = "16.4.2"
  create_namespace = true
    values = [
        <<-EOF
        useStatefulSet: true
        auth:
          rootUser: root
          rootPassword: ${random_password.db_password.result}
        nodeSelector:
          nodegroup: "mongodb"
        global:
          storageClass: "gp2"
         
        EOF
    ]
}
# module "mongodb" {
#   source  = "squareops/mongodb/kubernetes"
#   version = "2.1.1"
#   namespace = "db"
#   create_namespace = true
#   mongodb_backup_config = {
#     architecture                     = "replicaset"
#     storage_class_name               = "gp2" 
#     values_yaml = [
#         <<-EOF
#     primary:
#     nodeSelector:
#         eks.amazonaws.com/nodegroup: "mongodb"

#     secondary:
#     nodeSelector:
#         eks.amazonaws.com/nodegroup: "mongodb"

#     arbiter:
#     nodeSelector:
#         eks.amazonaws.com/nodegroup: "mongodb"
#     EOF
#     ]
#   }
#   mongodb_custom_credentials_enabled = true
#   mongodb_custom_credentials_config = {
#     root_user                = "root"
#     root_password            = random_password.db_password.result
#   }
# }