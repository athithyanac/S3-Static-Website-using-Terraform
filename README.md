# S3-Website-using-Terraform
## Features
Easy to customise and use.
Each CIDR subnet block created using cidrsubnet().
Tfvars file to modify variables.


## Prerequisites
Need AWS CLI access or IAM user access with policies attached for S3.
Terraform need to be installed. Click to download [Terraform](https://www.terraform.io/downloads "Terraform").

## Variables
```terraform
variable "access_key" {}
variable "secret_key" {}
variable "project" {}
variable "region" {}
variable "domain" {}
variable "mime_types" {   
  default = {  
    htm   : "text/html"
    html  : "text/html"
    css   : "text/css"
    ttf   : "font/ttf"
    json  : "application/json"
    png	  : "image/png"
    jpg   : "image/jpeg"    
    woff2 : "font/woff2" 
    woff  : "font/woff"
    eot	  : "application/vnd.ms-fontobject" 
    js	  : "text/javascript"
    otf   : "font/otf"
    svg   : "image/svg+xml"
    mp4   : "video/mp4"
    txt   : "text/plain"
    }
}
```

## Create an S3 bucket
```terraform
resource "aws_s3_bucket" "mybucket" {
  bucket = "${var.project}.${var.domain}"
  tags = {
    Name = var.project
  }
}
```
# Enabling static website
```terraform
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.mybucket.bucket
  index_document {
    suffix = "index.html"
  }
}
```
# Creating bucket policy for public access
```terraform
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
```
# Uploading files to S3
```terraform
resource "aws_s3_object" "object" {
  for_each = fileset("C:\\Users\\Adi\\Downloads\\2129_crispy_kitchen\\","**")
  bucket = aws_s3_bucket.mybucket.id
  key    = each.value
  source = "C:\\Users\\Adi\\Downloads\\2129_crispy_kitchen\\${each.value}"

  etag = filemd5("C:\\Users\\Adi\\Downloads\\2129_crispy_kitchen\\${each.value}")
  content_type  = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}
```
# Find Zone ID and map website url with S3 endpoint
```terraform
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
```
## Output
```terrraform
output "bucket_name" {
    value = aws_s3_bucket.mybucket.bucket
}
output "bucket_website_endpoint" {
  value = "http://${aws_s3_bucket.mybucket.website_endpoint}"
}
output "website" {
  value = "http://${var.project}.${var.domain}"
}
```
