provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name, "--profile", var.profile]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
  }
}
resource "kubernetes_secret" "example" {
  depends_on = [
     kubernetes_namespace.airflow,
  ]
  metadata {
    namespace =  "airflow"
    name = "airflow-ssh-git-secret"
  }
  data = {
    "id_rsa" = "${file("id_rsa")}"
  }

}

resource "kubernetes_config_map" "example" {
  depends_on = [
     kubernetes_namespace.airflow,
  ]
  metadata {
    namespace =  "airflow"
    name = "dashboards"
  }

  data = {
    "dashboards" = "${file("configmap.yaml")}"
  }
}





