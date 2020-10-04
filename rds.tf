resource "aws_db_subnet_group" "wordpress_db_subnets" {
  name       = "wordpress_db_subnets"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "My WordPress DB subnet group"
  }
}

resource "aws_rds_cluster" "wordpress_db_cluster" {
  cluster_identifier = "wordpress-aurora-cluster"
  engine             = var.db_engine
  engine_version     = var.db_engine_version
  port               = var.db_port
  database_name      = aws_ssm_parameter.db_name.value
  master_username    = aws_ssm_parameter.db_username.value
  master_password    = aws_ssm_parameter.db_password.value

  db_subnet_group_name    = aws_db_subnet_group.wordpress_db_subnets.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "wordpress_cluster_instances" {
  count                = 2
  identifier           = "wordpress-db-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.wordpress_db_cluster.id
  instance_class       = var.db_instance_type
  engine               = aws_rds_cluster.wordpress_db_cluster.engine
  engine_version       = aws_rds_cluster.wordpress_db_cluster.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_rds_cluster.wordpress_db_cluster.db_subnet_group_name
}

