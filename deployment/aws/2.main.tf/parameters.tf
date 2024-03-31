resource "aws_ssm_parameter" "allowed_hosts" {
  name        = "/todo_api/ALLOWED_HOSTS"
  type        = "String"
  value       = "*"
  description = "Comma separated frontend domains that should be allowed to communicate to api via web browser"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "debug" {
  name  = "/todo_api/DEBUG"
  type  = "String"
  value = "False"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/todo_api/DB_NAME"
  type  = "String"
  value = "todo_api_db"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_user" {
  name  = "/todo_api/DB_USER"
  type  = "String"
  value = "todo_api_user"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_writer_host" {
  name  = "/todo_api/DB_WRITER_HOST"
  type  = "String"
  value = module.aurora_postgresql_v2.cluster_endpoint

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_reader_host" {
  name  = "/todo_api/DB_READER_HOST"
  type  = "String"
  value = module.aurora_postgresql_v2.cluster_reader_endpoint

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/todo_api/DB_PORT"
  type  = "String"
  value = "5432"

  lifecycle {
    ignore_changes = [value]
  }
}