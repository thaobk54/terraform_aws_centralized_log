# variable "public_subnet" {
#   description = "Which Subnet ID does EC2 belong?"
# }

# variable "aws_instance_type" {
#   description = "What is the EC2 instance type you want to run?"
# }

# variable "aws_key_name" {
#   description = "What is your SSH Key name?"
# }

# variable "vpc_security_group_ids" {
#   description = "What is the security group for this EC2?"
# }

# variable "iam_instance_profile" {
#   description = "What is the EC2 instance profile you want to attach ?"
# }

variable "sqs_id" {
  description = "SQS id for Cloud Trail in Filebeat"
}

variable "cloud_id" {
  description = "ELK id"
  type = string
}

variable "cloud_auth" {
  description = "ELK auth"
  type = string
}

