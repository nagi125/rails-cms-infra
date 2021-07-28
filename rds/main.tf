variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "database_name" {
  type = string
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}

locals {
  name = "${var.app_name}-pgsql"
}

resource "aws_security_group" "this" {
  name        = local.name
  description = local.name

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.name
  }
}

resource "aws_security_group_rule" "pgsql" {
  security_group_id = aws_security_group.this.id

  type = "ingress"

  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["10.1.0.0/16"]

}

resource "aws_db_subnet_group" "this" {
  name        = local.name
  description = local.name
  subnet_ids  = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier = local.name
  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  engine = "postgres"
  engine_version = "12.5"
  instance_class = "db.t3.micro"
  port = 5432
  name = var.database_name
  username = var.master_username
  password = var.master_password

  final_snapshot_identifier = local.name
  skip_final_snapshot = true

  # Storage
  allocated_storage     = 10
  max_allocated_storage = 30
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}