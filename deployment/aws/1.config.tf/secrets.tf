resource "aws_secretsmanager_secret" "todo_api_db_password" {
  name = "/todo_api/DB_PASSWORD"
}

resource "random_password" "todo_api_db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
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