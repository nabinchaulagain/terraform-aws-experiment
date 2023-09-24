resource "aws_db_subnet_group" "default" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids
}

resource "random_password" "db_master_user" {
  length = 15
}


resource "aws_security_group" "db" {
  name   = "${var.cluster_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags,
    {
      Name = "${var.cluster_name}-sg"
    }
  )

}

resource "aws_rds_cluster" "default" {
  cluster_identifier     = var.cluster_name
  db_subnet_group_name   = aws_db_subnet_group.default.name
  engine                 = var.engine
  database_name          = var.db_name
  master_username        = var.db_master_username
  master_password        = random_password.db_master_user.result
  vpc_security_group_ids = [aws_security_group.db.id]
  port                   = var.port
  skip_final_snapshot    = true
  storage_encrypted      = true
  apply_immediately      = true

  tags = merge(var.common_tags,
    {
      Name = var.db_name
    }
  )
}

resource "aws_rds_cluster_instance" "default" {
  count                = length(var.subnet_ids)
  cluster_identifier   = aws_rds_cluster.default.id
  publicly_accessible  = var.is_publicly_accessible
  instance_class       = var.instance_class
  identifier           = "${aws_rds_cluster.default.cluster_identifier}-instance-${count.index}"
  engine               = aws_rds_cluster.default.engine
  engine_version       = aws_rds_cluster.default.engine_version
  db_subnet_group_name = aws_rds_cluster.default.db_subnet_group_name

  tags = merge(var.common_tags,
    {
      Name = "${aws_rds_cluster.default.cluster_identifier}-instance-${count.index}"
    }
  )
}
