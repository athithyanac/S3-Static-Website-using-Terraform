output "bucket_name" {
    value = aws_s3_bucket.mybucket.bucket
}
output "website_endpoint" {
  value = "http://${aws_s3_bucket.mybucket.website_endpoint}"
}
output "website" {
  value = "http://${var.project}.${var.domain}"
}