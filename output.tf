
# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc.private_subnets}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.vpc.public_subnets}"]
}

# Public security group
output "public_sg" {
  value     = "${aws_security_group.demo-test-pub-sg.id}"
}

# Private security group
output "private_sg" {
  value     = "${aws_security_group.demo-test-pvt-sg.id}"
}

# Public EC2 instance - Jenkins
output "jenkins_ip" {
  value     = "${aws_instance.demo-test-jenkins.public_ip}"
}

# Private EC2 instance - App Server
output "app_server_ip" {
  value     = "${aws_instance.demo-test-app-server.private_ip}"
}
