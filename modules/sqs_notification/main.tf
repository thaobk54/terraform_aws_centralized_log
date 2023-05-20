#### SQS####
locals {
  cloudtrail_logs_path = var.cloudtrail_logs_prefix == "" ? "AWSLogs" : "${var.cloudtrail_logs_prefix}/AWSLogs"
  elb_logs_path = var.elb_logs_prefix == "" ? "AWSLogs" : "${var.elb_logs_prefix}/AWSLogs"
}

data "aws_elb_service_account" "main" {
}

data "aws_region" "current" {}

resource "aws_sqs_queue" "elk_queue" {
  name = "${var.stack_name}-elk-s3-event-notification-queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS":"*"  
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${var.stack_name}-elk-s3-event-notification-queue",
      "Condition": {
        "ArnLike": { "aws:SourceArn": "arn:aws:s3:*:*:${aws_s3_bucket.elk_log.id}" }
      }
    }
  ]
}
POLICY
}



resource "aws_s3_bucket" "elk_log" {
  bucket = "${var.stack_name}-elk-log"
  force_destroy = true
  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [{
			"Sid": "AWSAclCheck20150319",
			"Effect": "Allow",
			"Principal": {
				"Service": [
					"cloudtrail.amazonaws.com",
					"logs.${data.aws_region.current.name}.amazonaws.com"
				]
			},
			"Action": "s3:GetBucketAcl",
			"Resource": "arn:aws:s3:::${var.stack_name}-elk-log"
		},
		{
			"Sid": "AWSCloudTrailWrite20150319",
			"Effect": "Allow",
			"Principal": {
				"Service": "cloudtrail.amazonaws.com"
			},
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::${var.stack_name}-elk-log/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-acl": "bucket-owner-full-control"
				}
			}
		},
    {
			"Sid": "AWSCloudLogWrite20150319",
			"Effect": "Allow",
			"Principal": {
				"Service": "logs.${data.aws_region.current.name}.amazonaws.com"
			},
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::${var.stack_name}-elk-log/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-acl": "bucket-owner-full-control"
				}
			}
		},
    {
			"Sid": "AWSELBWrite20150319",
			"Effect": "Allow",
			"Principal": {
				"AWS": "${data.aws_elb_service_account.main.arn}"
			},
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::${var.stack_name}-elk-log/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-acl": "bucket-owner-full-control"
				}
			}
		}

	]
}
POLICY
}

resource "aws_s3_bucket_notification" "elk_bucket_notification" {
  bucket = aws_s3_bucket.elk_log.id

  queue {
    queue_arn     = aws_sqs_queue.elk_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = local.cloudtrail_logs_path
  }
  queue {
    queue_arn     = aws_sqs_queue.elk_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.cloudwatch_logs_prefix
  }
  
  queue {
    queue_arn     = aws_sqs_queue.elk_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = local.elb_logs_path
  }
  # dynamic "queue" {
  #   for_each = toset(var.alb_logs_prefixes)
  #   content {
  #     queue_arn     = aws_sqs_queue.elk_queue.arn
  #     events        = ["s3:ObjectCreated:*"]
  #     filter_prefix = "${queue.value}/"
  #   }
  # }
}

#### CloudTrail Log ####
# resource "aws_cloudtrail" "elk_trail_log" {
#   name                          = "${var.stack_name}-trail-logs"
#   s3_bucket_name                = aws_s3_bucket.elk_log.id
#   s3_key_prefix = ""
#   include_global_service_events = true
# }

#### EC2 Log ####

# module "cloudwatch-logs-exporter" {
#   for_each = toset(var.log_groups)
#   source  = "../sqs_notificaton"
#   schedule = "cron(*/5 * * * ? *)"
#   s3_bucket        = aws_s3_bucket.elk_log.id
#   name = "${var.stack_name}-${each.value}"
#   log_group        = each.value
#   s3_prefix        = each.value
# }

