data "aws_ssm_parameter" "db_name" {
  name = "/todo_api/DB_NAME"
}

data "aws_ssm_parameter" "db_user" {
  name = "/todo_api/DB_USER"
}

data "aws_secretsmanager_secret_version" "todo_api_db_password" {
  secret_id = "/todo_api/DB_PASSWORD"
}