provider "helm" {  
    kubernetes {    
        host                   = aws_eks_cluster.eks_cluster.endpoint
        cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)    
        exec {      
            api_version = "client.authentication.k8s.io/v1alpha1"      
            args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--profile", var.profile]
            command     = "aws"    
        }  
    }   
}

resource "helm_release" "airflow-stable" {
  name       = "airflow-stable"
  repository = "https://airflow-helm.github.io/charts"
  chart      = "airflow"
  namespace = "airflow"
  timeout = 900

  values = [
    file("final.yaml")
  ]
  depends_on = [
     kubernetes_namespace.airflow,
     kubernetes_secret.example,
     kubernetes_config_map.example,
  ]
}

resource "helm_release" "monitoring" {
  name       = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace = "airflow"

  values = [
    file("loki.yaml")
  ]
  depends_on = [
     kubernetes_namespace.airflow,
     kubernetes_secret.example,
     kubernetes_config_map.example,
  ]
}
