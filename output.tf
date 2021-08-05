output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_status" {
  value = aws_eks_cluster.eks_cluster.status
}


output "node-group-name" {
  value = aws_eks_node_group.node-group.id
}
