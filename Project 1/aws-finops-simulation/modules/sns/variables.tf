variable "sns_topic_name" {
  default = "finops-alerts-topic"
  type = string
  description = "Name of sns topic"
}

variable "alert_email" {
  default = "swapnil.cloud.dev@hotmail.com"
  type = string
  description = "Email of subscriber"
}
