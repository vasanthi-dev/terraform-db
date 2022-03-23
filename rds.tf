resource "aws_db_instance" "default" {
  identifier           = "mysql-${var.ENV}"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "sample"
  username             = jsondecode(data.aws_secretsmanager_secret_version.dev-secrets.secret_string)["RDS_MYSQL_USER"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.dev-secrets.secret_string)["RDS_MYSQL_PASS"]
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
}

resource "aws_db_subnet_group" "default" {
  name       = "mysql-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS

  tags = {
    Name = "mysql-${var.ENV}"
  }
}

resource "aws_security_group" "mysql" {
  name        = "sg_mysql_${var.ENV}"
  description = "sg_mysql_${var.ENV}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description      = "APP"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = concat(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_CIDR, tolist([data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR]))
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_mysql_${var.ENV}"
  }
}

resource "null_resource" "mysql-schema" {
  provisioner "local-exec" {
    command = <<-EOF
sudo yum install mariadb -y
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
cd /tmp
unzip -o mysql.zip
cd mysql-main
mysql -h ${aws_db_instance.default.address} -u${jsondecode(data.aws_secretsmanager_secret_version.dev-secrets.secret_string)["RDS_MYSQL_USER"]} -p${jsondecode(data.aws_secretsmanager_secret_version.dev-secrets.secret_string)["RDS_MYSQL_PASS"]} <shipping.sql
EOF
  }
}

resource "aws_route53_record" "mysql" {
  zone_id = data.terraform_remote_state.vpc.outputs.PRIVATE_HOSTED_ZONEID
  name    = "mysql-${var.ENV}.roboshop.internal"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.default.address]
}