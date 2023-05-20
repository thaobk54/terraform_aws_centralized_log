
- module: aws
  cloudtrail:
    enabled: true
    # AWS SQS queue url
    var.queue_url: ${queue_id}
    # Default to be 300s
    var.visibility_timeout: 300s
    # AWS IAM Role to assume
    var.role_arn: ${iam_role}
  cloudwatch:
    enabled: true
    # AWS SQS queue url
    var.queue_url: ${queue_id}
    # Default to be 300s
    var.visibility_timeout: 300s
    # AWS IAM Role to assume
    var.role_arn: ${iam_role}
  ec2:
    enabled: true
    # AWS SQS queue url
    var.queue_url: ${queue_id}
    # Default to be 300s
    var.visibility_timeout: 300s
    # AWS IAM Role to assume
    var.role_arn: ${iam_role}
  elb:
    enabled: true
    # AWS SQS queue url
    var.queue_url: ${queue_id}
    # Default to be 300s
    var.visibility_timeout: 300s
    # AWS IAM Role to assume
    var.role_arn: ${iam_role}
  s3access:
    enabled: false
  vpcflow:
    enabled: false
