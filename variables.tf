variable "region" {
  description = "AWS region for the project"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Name used to label every resource"
  type        = string
  default     = "tf-aws-project"
}

variable "public_subnet_cidrs" {
  description = "IP ranges of the public subnets, one per availability zone"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "IP ranges of the private subnets, one per availability zone"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 server size"
  type        = string
  default     = "t3.micro"
}