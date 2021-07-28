variable "zone" {
  type = string
}

variable "domain" {
  type = string
}

data "aws_route53_zone" "main" {
  name         = var.zone
  private_zone = false
}

resource "aws_ses_domain_identity" "ses" {
  domain = var.domain
}

resource "aws_route53_record" "ses_record" {
  zone_id = data.aws_route53_zone.main.id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.ses.verification_token}"]
}

resource "aws_ses_domain_identity_verification" "domain_verification" {
  domain     = aws_ses_domain_identity.ses.id
  depends_on = [aws_route53_record.ses_record]
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = var.domain
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.main.id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
