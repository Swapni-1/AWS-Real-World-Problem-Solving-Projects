
output "s3_outputs" {
  value = {
    # ec2_instance_profile_name = aws_iam_instance_profile.ec2_profile.name
    bucket_name = aws_s3_bucket.my_bucket.bucket
    bucket_arn = aws_s3_bucket.my_bucket.arn
  }
}