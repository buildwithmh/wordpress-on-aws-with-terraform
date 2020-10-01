#Gnerate Random username and password
resource "random_string" "username" {
  length           = 16
  special          = true
  override_special = "-"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}


#Storing all credentials as a System Manager Parameter Store parameters 
resource "aws_ssm_parameter" "db_name" {
  name        = format("/%s/db-server/name", var.env)
  description = "Database name for wordpress"
  type        = "String"
  value       = "wordpress_db"
}

resource "aws_ssm_parameter" "db_username" {
  name        = format("/%s/db-server/username", var.env)
  description = "Database username to be created in $db_name database"
  type        = "String"
  value       = random_string.username.result
}

resource "aws_ssm_parameter" "db_password" {
  name        = format("/%s/db-server/password", var.env)
  description = "Database password for $db_username"
  type        = "SecureString"
  value       = random_password.password.result
}

resource "aws_ssm_parameter" "wp_title" {
  name        = format("/%s/wordpress/title", var.env)
  description = "Wordpress website title"
  type        = "String"
  value       = "The Coolest Wordpress Site"
}

resource "aws_ssm_parameter" "wp_username" {
  name        = format("/%s/wordpress/username", var.env)
  description = "WordPress Admin username"
  type        = "String"
  value       = random_string.username.result
}

resource "aws_ssm_parameter" "wp_password" {
  name        = format("/%s/wordpress/password", var.env)
  description = "WordPress Admin password"
  type        = "SecureString"
  value       = random_password.password.result
}

resource "aws_ssm_parameter" "wp_email" {
  name        = format("/%s/wordpress/email", var.env)
  description = "WordPress Admin email"
  type        = "String"
  value       = var.wp_admin_email
}

resource "aws_ssm_parameter" "site_url" {
  name        = format("/%s/wordpress/site_url", var.env)
  description = "WordPress site url"
  type        = "String"
  value       = format("http://%s", aws_lb.wordpress_lb.dns_name)
}

