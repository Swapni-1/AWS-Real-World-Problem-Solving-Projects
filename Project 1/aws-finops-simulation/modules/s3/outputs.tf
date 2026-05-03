output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.my_bucket.arn
}