locals {
  cluster_name = "12factor-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "12factor-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)


  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  database_subnets             = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  database_subnet_group_name   = "subnet-group"
  create_database_subnet_group = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.cloudwatch.arn
    }
  }

  fargate_profiles = {
    workloads = {
      name       = "fp-workloads"
      subnet_ids = module.vpc.private_subnets
      selectors = [
        {
          namespace = "todo-api"
        },
        {
          namespace = "default"
        }
      ]
    },
    system = {
      name       = "fp-system"
      subnet_ids = module.vpc.private_subnets
      selectors = [
        {
          namespace = "kube-system"
        },
        {
          namespace = "aws-observability"
        }
      ]
    }
  }
}

resource "aws_iam_policy" "cloudwatch" {
  name = "${local.cluster_name}-cloudwatch-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}