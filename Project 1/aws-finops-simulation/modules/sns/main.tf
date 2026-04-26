resource "aws_sns_topic" "my_sns" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.my_sns.arn
  protocol = "email"
  endpoint = var.alert_email
}

# sns topic policy

# resource "aws_sns_topic_policy" "allow_cloudwatch" {
#   arn = aws_sns_topic.my_sns.arn
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#         {
#             Effect = "Allow"
#             Principal = {
#                 AWS = "*"
#             }
#             Action = [
#                 "SNS:GetTopicAttributes",
#                 "SNS:SetTopicAttributes",
#                 "SNS:AddPermission",
#                 "SNS:RemovePermission",
#                 "SNS:DeleteTopic",
#                 "SNS:Subscribe",
#                 "SNS:ListSubscriptionsByTopic",
#                 "SNS:Publish"
#             ]
#             Resource = aws_sns_topic.my_sns.arn
#             Condition = {
#                 StringEquals = {
#                     "AWS:SourceOwner" = "598120810611"
#                 }
#             }
#         },
#         {
#             Effect = "Allow"
#             Principal = {
#                 Service = "cloudwatch.amazonaws.com"
#             }
#             Action = "sns:Publish"
#             Resource = aws_sns_topic.my_sns.arn
#         }
#     ]
#   })
# }