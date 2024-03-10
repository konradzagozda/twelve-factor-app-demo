resource "aws_ecr_repository" "todo_api_job" {
  name                 = "todo-api-job"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "todo_api_web" {
  name                 = "todo-api-web"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}