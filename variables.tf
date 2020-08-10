variable region {
  type        = string
  default     = ""
  description = "Your preferred region"
}

variable instance_tag {
  type        = map
  description = "A custom tag applied to your instances that the scheduler should look for"
}

variable start_cron {
  type        = string
  default     = ""
  description = "An AWS CloudWatch cron expression for use in starting instances"
}

variable stop_cron {
  type        = string
  default     = ""
  description = "An AWS CloudWatch cron expression for use in stopping instances"
}