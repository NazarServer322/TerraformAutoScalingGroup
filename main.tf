provider "aws" {
  region     = var.region
 # access_key = var.aws_access_key
 # secret_key = var.aws_secret_key
}

resource "aws_security_group" "web_server" {
  vpc_id = aws_vpc.main_vpc.id
  name_prefix = "web"
  dynamic "ingress" {
    for_each = var.security_port
    content {
      from_port = ingress.value
      protocol = "tcp"
      to_port = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


