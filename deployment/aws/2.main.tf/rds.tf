data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "15.4"
}

module "aurora_postgresql_v2" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.3.1"

  name              = "todo-api-db-postgresqlv2"
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true

  manage_master_user_password = false
  master_username             = aws_ssm_parameter.db_user.value
  database_name               = aws_ssm_parameter.db_name.value
  master_password             = aws_secretsmanager_secret_version.todo_api_db_password.secret_string

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 10
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }
}