# Creating S3 bucket 
resource "aws_s3_bucket" "mybucket" {
  bucket = "${var.project}.${var.domain}"
  tags = {
    Name = var.project
  }
}
# Enabling static website
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.mybucket.bucket
  index_document {
    suffix = "index.html"
  }
}
# Configuring a bucket policy for public access
data "aws_iam_policy_document" "access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.mybucket.arn,
      "${aws_s3_bucket.mybucket.arn}/*",
    ]
  }
}
resource "aws_s3_bucket_policy" "allow_access" {
  bucket = aws_s3_bucket.mybucket.id
  policy = data.aws_iam_policy_document.access.json
}
# Find Zone ID and map website url to S3 endpoint
data "aws_route53_zone" "zoneid" {
  name = var.domain
}
resource "aws_route53_record" "route" {
  zone_id = data.aws_route53_zone.zoneid.zone_id
  name = "${var.project}.${var.domain}"
  type = "CNAME"
  ttl = "5"
  records = [aws_s3_bucket_website_configuration.site.website_endpoint]
}
# Uploading files to S3
resource "aws_s3_object" "object" {
  for_each = fileset("C:\\Users\\Adi\\Downloads\\2129_crispy_kitchen\\","**")
  bucket = aws_s3_bucket.mybucket.id
  key    = each.value
  source = "C:\\Users\\Adi\\Downloads\\2129_crispy_kitchen\\${each.value}"

  etag = filemd5("C:\\Users\\Adi\\Downloads\\2129_crispy_kitchen\\${each.value}")
  content_type  = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}
