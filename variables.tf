variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "stack_name" {
  description = "The name of stack of resources"
  default = "elkstack"
}

variable "log_groups" {
  description = "Log groups are monitored on ELK"
  type = list(string)
  default = ["elk-ec2-log-group"]
}

variable "elb_logs_prefix" {
  description = "S3 prefix for ELB logs."
  default     = "elb"
  type        = string
}

variable "cloudwatch_logs_prefix" {
  description = "S3 prefix for CloudWatch log exports."
  default     = "cloudwatch"
  type        = string
}

variable "cloudtrail_logs_prefix" {
  description = "S3 prefix for CloudTrail logs."
  default     = "cloudtrail"
  type        = string
}

variable "cloud_id" {
  description = "ELK id"
  type = string
}

variable "cloud_auth" {
  description = "ELK auth"
  type = string
}




