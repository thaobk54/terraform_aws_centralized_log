variable "stack_name" {
  description = "The name of stack of resources"
}

variable "s3_bucket" {
  description = "The name of S3 where to store the logs"
}

variable "elb_logs_prefix" {
  description = "S3 prefix for ELB logs."
  type        = string
}

variable "cloudwatch_logs_prefix" {
  description = "S3 prefix for CloudWatch log exports."
  type        = string
}

variable "cloudtrail_logs_prefix" {
  description = "S3 prefix for CloudTrail logs."
  type        = string
}
