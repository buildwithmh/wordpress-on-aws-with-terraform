resource "aws_elasticache_subnet_group" "memcached_subnet_group" {
  name       = "memcached-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id
}

resource "aws_elasticache_cluster" "memcached_cluster" {
  cluster_id         = "wordpress-cluster"
  engine             = "memcached"
  node_type          = var.ec_node_type
  num_cache_nodes    = var.ec_nodes_count
  az_mode            = var.ec_az_mode
  port               = var.ec_memcached_port
  subnet_group_name  = aws_elasticache_subnet_group.memcached_subnet_group.name
  security_group_ids = [aws_security_group.memcached_sg.id]
}

