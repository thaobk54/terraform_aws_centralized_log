
# module "logs" {
#   source  = "trussworks/logs/aws"
#   version = "10.2.0"
#   s3_bucket_name = "${var.stack_name}-elk-log"
#   default_allow     = false
#   allow_config      = false
#   allow_nlb = false
#   allow_redshift = false
#   allow_alb = false

#   allow_cloudtrail = true
#   cloudtrail_logs_prefix = var.cloudtrail_logs_prefix
  
#   allow_cloudwatch = true
#   cloudwatch_logs_prefix = var.cloudwatch_logs_prefix

#   allow_elb         = true
#   elb_logs_prefix   = var.elb_logs_prefix
  
#   force_destroy = true
# }

module "sqs_notificaton" {
  source                  = "./modules/sqs_notification"
  stack_name = var.stack_name
  s3_bucket = ""

  cloudtrail_logs_prefix = var.cloudtrail_logs_prefix
  
  cloudwatch_logs_prefix = var.cloudwatch_logs_prefix

  elb_logs_prefix   = var.elb_logs_prefix

}

#### EC2 metricbeat ####
module "ec2_metricbeat" {
  source                  = "./modules/ec2"
  sqs_id = module.sqs_notificaton.queue_id
  cloud_id = var.cloud_id
  cloud_auth = var.cloud_auth
}

# #### CloudTrail Log ####
# resource "aws_cloudtrail" "elk_trail_log" {
#   name                          = "${var.stack_name}-trail-logs"
#   s3_bucket_name                = module.sqs_notificaton.aws_logs_bucket
#   s3_key_prefix = var.cloudtrail_logs_prefix
#   include_global_service_events = true
# }

# #### ELB Access Log ####
# module "ec2-instance_example_elb" {
#   source  = "./modules/ec2-instance_example_elb"
#   s3_bucket = module.sqs_notificaton.aws_logs_bucket
#   elb_logs_prefix = var.elb_logs_prefix
# }

# #### Cloudwatch Log Group to S3 ####
# module "cloudwatch-logs-exporter" {
#   for_each = toset(var.log_groups)
#   source  = "./modules/cloudwatch_s3_exporter"
#   schedule = "cron(*/5 * * * ? *)"
#   s3_bucket        = module.sqs_notificaton.aws_logs_bucket
#   name = "${var.stack_name}-${each.value}"
#   log_group        = each.value
#   s3_prefix        = var.cloudwatch_logs_prefix
# }

