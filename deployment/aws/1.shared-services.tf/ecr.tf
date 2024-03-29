locals {
  ecr_policy_template = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPushPull",
        Effect = "Allow",
        Principal = {
          AWS = [
            for account_id in var.aws_account_ids : "arn:aws:iam::${account_id}:root"
          ]
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

resource "aws_ecr_repository" "todo_api_job" {
  name                 = "todo-api-job"
  image_tag_mutability = "IMMUTABLE"

  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "todo_api_job_policy" {
  repository = aws_ecr_repository.todo_api_job.name
  policy     = local.ecr_policy_template
}


resource "aws_ecr_repository" "todo_api" {
  name                 = "todo-api"
  image_tag_mutability = "IMMUTABLE"

  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "todo_api_policy" {
  repository = aws_ecr_repository.todo_api.name
  policy     = local.ecr_policy_template
}
