resource "aws_secretsmanager_secret" "todo_api_db_password" {
  name                    = "/todo_api/DB_PASSWORD"
  recovery_window_in_days = 0
}

resource "random_password" "todo_api_db_password" {
  length  = 16
  special = false
  keepers = {
    id = aws_secretsmanager_secret.todo_api_db_password.id
  }
}

resource "aws_secretsmanager_secret_version" "todo_api_db_password" {
  secret_id     = aws_secretsmanager_secret.todo_api_db_password.id
  secret_string = random_password.todo_api_db_password.result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "todo_api_secret_key" {
  name                    = "/todo_api/SECRET_KEY"
  recovery_window_in_days = 0
}

resource "random_password" "todo_api_secret_key" {
  length  = 50
  special = false
}

resource "aws_secretsmanager_secret_version" "todo_api_secret_key" {
  secret_id     = aws_secretsmanager_secret.todo_api_secret_key.id
  secret_string = random_password.todo_api_secret_key.result

  lifecycle {
    ignore_changes = [secret_string]
  }
}