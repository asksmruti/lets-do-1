/* vpc, nat-gw & igw */

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "demo-test-vpc"
  cidr = "${var.vpc_cidr}"

  azs             = ["${var.avlzs}"]
  private_subnets = ["${var.prsr}"]
  public_subnets  = ["${var.pbsr}"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

/* public subnet security group */

resource "aws_security_group" "demo-test-pub-sg" {
  name = "demo-test-pub-sg"
  description = "HTTP & SSH access to Jenkins server"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.pbsg}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.pbsg}"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id="${module.vpc.vpc_id}"

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "demo-test-pub-sg"
  }
}

resource "aws_security_group" "demo-test-pvt-sg" {
  name = "demo-test-pvt-sg"
  description = "Allow only SSH access within vpc"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.prsg}"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id="${module.vpc.vpc_id}"

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "demo-test-pvt-sg"
  }
}

###### EC2 instances ######

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "demo-test-app-server" {
  ami                       = "${data.aws_ami.ubuntu.id}"
  instance_type             = "${var.instance_type}"
  vpc_security_group_ids    = ["${aws_security_group.demo-test-pvt-sg.id}"]
  key_name                  = "${var.ec2_key}"
  subnet_id                 = "${element(module.vpc.private_subnets,0)}"

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "demo-test-jenkins"
  }
}
resource "aws_instance" "demo-test-jenkins" {
  ami                       = "${data.aws_ami.ubuntu.id}"
  instance_type             = "${var.instance_type}"
  vpc_security_group_ids    = ["${aws_security_group.demo-test-pub-sg.id}"]
  key_name                  = "${var.ec2_key}"
  subnet_id                 = "${element(module.vpc.public_subnets,0)}"

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("${var.key_path}")}"
    agent = true
  } 

  provisioner "file" {
    source      = "tools.sh"
    destination = "/tmp/tools.sh"
  }

  provisioner "file" {
    source      = "${var.key_path}"
    destination = "/tmp/general-test.pem"
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/tools.sh",
      "/tmp/tools.sh ubuntu ${aws_instance.demo-test-app-server.private_ip} > /tmp/general-test.out",
      "rm -rf /tmp/tools.sh",
    ]
  }
  tags = {
    Terraform = "true"
    Name = "demo-test-app-server"
    Environment = "dev"
  }
}
