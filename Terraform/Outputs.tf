output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.id
}