output "todo_api_job_repository_url" {
  value = aws_ecr_repository.todo_api_job.repository_url
}

output "todo_api_repository_url" {
  value = aws_ecr_repository.todo_api.repository_url
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
