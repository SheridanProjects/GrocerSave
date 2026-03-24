resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = var.eks_cluster_role_arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids = [for s in aws_subnet.public : s.id]
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = [for s in aws_subnet.public : s.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Using t4g.medium as a cost-effective default.
  # For your full stack, you might need to scale up to t4g.xlarge.
  instance_types = ["t4g.medium"]

  # The explicit depends_on is no longer needed as we are not creating the roles.
}
