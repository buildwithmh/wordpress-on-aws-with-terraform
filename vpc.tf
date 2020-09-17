resource "aws_security_group" "ssh_and_http" {
  name        = "ssh-http-sg"
  description = "Allow SHH & HTTP traffic from any source to the instance"

  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
