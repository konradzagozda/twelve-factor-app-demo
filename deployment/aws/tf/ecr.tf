resource "aws_ecr_repository" "todo_api_job" {
  name                 = "todo-api-job"
  image_tag_mutability = "IMMUTABLE"

  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "todo_api" {
  name                 = "todo-api"
  image_tag_mutability = "IMMUTABLE"

  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}