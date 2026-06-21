# membuat IAM Role untuk EKS
resource "aws_iam_role" "cluster" {
    name = "devops-learn-${var.environment}-eks-cluster-role"

    # Trust policy: yang boleh assume = service EKS
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
    role       = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
# akhir membuat IAM Role untuk EKS

# membuat IAM Role untuk node EKS
resource "aws_iam_role" "node" { 
    name = "devops-learn-${var.environment}-eks-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }   # 👈 EC2, BUKAN eks!
        Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "node_worker" {
    role       = aws_iam_role.node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_cni" {
    role       = aws_iam_role.node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "node_registry" {
    role       = aws_iam_role.node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
# akhir membuat IAM Role untuk node EKS


# Pembuatan EKS Cluster
resource "aws_eks_cluster" "main" {
    name = "devops-learn-${var.environment}"
    role_arn = aws_iam_role.cluster.arn
    vpc_config {
        subnet_ids = var.subnet_ids
    }
    depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# Pembuatan EKS Node Group
resource "aws_eks_node_group" "main" {
    cluster_name = aws_eks_cluster.main.name
    node_group_name = "devops-learn-${var.environment}-eks-node-group"
    node_role_arn = aws_iam_role.node.arn
    subnet_ids = var.subnet_ids

    scaling_config {
      desired_size = 2
      max_size = 3
      min_size = 1
    }

    instance_types = ["t3.micro"]

    depends_on = [
        aws_iam_role_policy_attachment.node_worker,
        aws_iam_role_policy_attachment.node_cni,
        aws_iam_role_policy_attachment.node_registry,
    ]

}