output "ec2_id" {
  value = aws_instance.metricbeat.*.id
}
output "ec2_public_ip" {
  value = aws_instance.metricbeat.*.public_ip
}