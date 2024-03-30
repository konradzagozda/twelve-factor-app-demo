output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "db_host" {
  description = "The database host (address) for connecting to the database"
  value       = aws_db_instance.todo_api_db.address
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "profile" {
  value = var.profile
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider
}

output "releases_bucket_name" {
  value = aws_s3_bucket.releases.bucket
}

output "configurations_bucket_name" {
  value = aws_s3_bucket.configurations.bucket
}