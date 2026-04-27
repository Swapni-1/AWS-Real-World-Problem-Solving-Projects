variable "sns_topic_name" {
  default = "finops-alerts-topic"
  type = string
  description = "Name of sns topic"
}

variable "alert_email" {
  default = "lojale9219@poisonword.com"
  type = string
  description = "Email of subscriber"
}