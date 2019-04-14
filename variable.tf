variable "region" {
  default       = "eu-central-1"
  description   = "set region"
}

variable "vpc_cidr" {
  type          = "string"
  description   = "vpc cidr range"
  default       = "172.20.0.0/16"
}

variable "avlzs" {
  type          = "list"
  description   = "list of availability zones for subnet"
  default       = ["eu-central-1a"]
}

variable "prsr" {
  type          = "list"
  description   = "private subnet range"
  default       = ["172.20.20.0/24"]
}

variable "pbsr" {
  type          = "list"
  description   = "public subnet range"
  default       = ["172.20.10.0/24"]
}

variable "pbsg" {
  type          = "list"
  description   = "public security group cider range"
  default       = ["188.103.25.171/32"]
}

variable "prsg" {
  type          = "list"
  description   = "private security group cider range"
  default       = ["172.20.10.0/24"]
}

variable "instance_type" {
  type          = "string"
  description   = "EC2 instance type"
  default       = "t2.medium"
}

variable "ec2_key" {
  type          = "string"
  description   = "key name to login EC2 instances"
  default       = "general-test"
}

variable "key_path" {
  type          = "string"
  description   = "pem file path to login EC2 instances"
  default       = "./general-test.pem"
}

