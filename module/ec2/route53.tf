resource "aws_route53_record" "private-record" {
  zone_id = var.PRIVATE_HOSTED_ZONEID
  name    = "${var.DB_COMPONENT}-${var.ENV}.roboshop.internal"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_spot_instance_request.db.private_ip]
}