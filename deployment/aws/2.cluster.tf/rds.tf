resource "aws_db_instance" "todo_api_db" {
  identifier = "todo-api-db"
  allocated_storage    = 5
  db_name              = data.aws_ssm_parameter.db_name.value
  engine               = "postgres"
  engine_version       = "15.6"
  instance_class       = "db.t3.micro"
  username             = data.aws_ssm_parameter.db_user.value
  password             = data.aws_secretsmanager_secret_version.todo_api_db_password.secret_string
  db_subnet_group_name  = module.vpc.database_subnet_group_name
  skip_final_snapshot = true
}