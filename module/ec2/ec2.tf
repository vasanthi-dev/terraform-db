resource "aws_spot_instance_request" "db" {
  ami           = var.AMI
  instance_type = var.INSTANCE_TYPE

  tags = {
    Name = "${var.DB_COMPONENT}-${var.ENV}"
  }
  subnet_id = var.SUBNET_ID
  wait_for_fulfillment = true
  vpc_security_group_ids = [aws_security_group.sg.id]
}