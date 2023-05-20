output "queue_id" {
  value = aws_sqs_queue.elk_queue.id
}

output "aws_logs_bucket" {
  value = aws_s3_bucket.elk_log.id
}
