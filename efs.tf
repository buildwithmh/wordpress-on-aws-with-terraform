resource "aws_efs_file_system" "wordpress_fs" {
  creation_token   = "wordpress-file-system"
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_60_DAYS"
  }

  tags = {
    Name = "MyProduct"
  }
}

resource "aws_efs_mount_target" "wordpress_mount_targets" {
  count           = length(aws_subnet.private_subnets)
  file_system_id  = aws_efs_file_system.wordpress_fs.id
  subnet_id       = aws_subnet.private_subnets[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}
