variable "sns_topic_name" {
  default = "finops-alerts-topic"
  type = string
  description = "Name of sns topic"
}

variable "alert_email" {
  default = "swapnillakra822@gmail.com"
  type = string
  description = "Email of subscriber"
}