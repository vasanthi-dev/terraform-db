resource "aws_security_group" "sg" {
  name        = "sg_${var.DB_COMPONENT}_${var.ENV}"
  description = "sg_${var.DB_COMPONENT}_${var.ENV}"
  vpc_id      = var.VPC_ID

  ingress {
    description      = "DB"
    from_port        = var.DB_PORT
    to_port          = var.DB_PORT
    protocol         = "tcp"
    cidr_blocks      = var.PRIVATE_SUBNET_CIDR
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.ALL_SUBNET_CIDR
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_${var.DB_COMPONENT}_${var.ENV}"
  }
}