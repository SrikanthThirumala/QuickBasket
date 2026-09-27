output "sri-img-products-profile-name" {
  value = aws_iam_instance_profile.sri-img-products-profile.name
  description = "sri-img-products role name value to pass it for ec2 "
}

output "sri-loki-logs-profile-name" {
  value = aws_iam_instance_profile.sri-loki-logs-profile.name
  description = "sri-loki-logs-profile name value to pass it for ec2 "
}

output "sri-frontend-iam-profile-name" {
  value = aws_iam_instance_profile.sri-frontend-iam-profile.name
  description = "sri-frontend role name value to pass it for ec2 "
}

