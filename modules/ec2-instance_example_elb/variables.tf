
variable "s3_bucket" {
  description = "The name of S3 where to store the logs"
}

variable "elb_logs_prefix" {
  description = "S3 prefix for ELB logs."
  type        = string
}

