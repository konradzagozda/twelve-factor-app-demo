resource "aws_db_instance" "todo_api_db" {
  identifier             = "todo-api-db"
  allocated_storage      = 5
  db_name                = aws_ssm_parameter.db_name.value
  engine                 = "postgres"
  engine_version         = "15.6"
  instance_class         = "db.t3.micro"
  username               = aws_ssm_parameter.db_user.value
  password               = aws_secretsmanager_secret_version.todo_api_db_password.secret_string
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.todo_api_db_sg.id]
}


resource "aws_security_group" "todo_api_db_sg" {
  name        = "todo-api-db-sg"
  description = "Security group for TODO API database"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "todo-api-db-sg"
  }
}

resource "aws_security_group_rule" "allow_all_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  security_group_id = aws_security_group.todo_api_db_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}