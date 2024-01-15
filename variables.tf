variable "region" {
  type        = string
  default     = ""
  description = "Your preferred region"
}

variable "tag_key" {
  type        = string
  description = "A custom tag applied to your instances that the scheduler should look for"
}

variable "function_name" {
  type        = string
  description = "Name of the Lambda function. Also used as a prefix for other resources"
}

variable "tag_value" {
  type        = string
  description = "A custom tag applied to your instances that the scheduler should look for"
}

variable "start_cron" {
  type        = string
  default     = ""
  description = "An AWS CloudWatch cron expression for use in starting instances"
}

variable "stop_cron" {
  type        = string
  default     = ""
  description = "An AWS CloudWatch cron expression for use in stopping instances"
}
