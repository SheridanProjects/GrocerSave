output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API."
  value       = aws_eks_cluster.main.endpoint
}

output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories."
  value = {
    for name, repo in aws_ecr_repository.main : name => repo.repository_url
  }
}

output "kubeconfig_command" {
  description = "The command to run to update your kubeconfig file."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
