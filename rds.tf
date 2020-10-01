resource "aws_db_subnet_group" "wordpress_db_subs" {
  name       = "wordpress_db_subnets"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "My WordPress DB subnet group"
  }
}

#resource "aws_db_instance" "default" {
#  instance_class        = var.db_instance_type
#  allocated_storage     = var.db_storage_capacity
#  max_allocated_storage = var.db_storage_capacity * 2
#  storage_type          = var.db_storage_type
#  engine                = var.db_engine
#  engine_version        = var.db_engine_version
#
#  multi_az                    = true
#  publicly_accessible         = false
#  allow_major_version_upgrade = true
#  auto_minor_version_upgrade  = true
#  skip_final_snapshot         = true
#  backup_retention_period     = 3
#
#
#
#  identifier           = "wordpress-db-instance"
#  name                 = aws_ssm_parameter.db_name.value
#  username             = aws_ssm_parameter.db_username.value
#  password             = aws_ssm_parameter.db_password.value
#  db_subnet_group_name = aws_db_subnet_group.wordpress_db_subs.name
#  parameter_group_name = "default.mysql5.7"
#}

resource "aws_rds_cluster" "wordpress_db_cluster" {
  cluster_identifier = "wordpress-aurora-cluster"
  engine             = var.db_engine
  engine_version     = var.db_engine_version

  database_name   = aws_ssm_parameter.db_name.value
  master_username = aws_ssm_parameter.db_username.value
  master_password = aws_ssm_parameter.db_password.value

  db_subnet_group_name    = aws_db_subnet_group.wordpress_db_subs.name
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

