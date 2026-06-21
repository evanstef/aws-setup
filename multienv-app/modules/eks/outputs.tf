output "cluster_name" {
    value = aws_eks_cluster.main.name
    description = "Nama cluster EKS"
}

output "cluster_endpoint" {
    value = aws_eks_cluster.main.endpoint
    description = "Endpoint cluster EKS"
}

output "cluster_ca_certificate" {
    value = aws_eks_cluster.main.certificate_authority[0].data
    description = "CA certificate cluster EKS"
}

output "node_group_name" {
    value = aws_eks_node_group.main.node_group_name
    description = "Nama node group EKS"
}