# AWS EC2 Region
variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

# AWS EC2 Instance Type
variable "aws_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.aws_instance_type)
    error_message = "Instance type must be a free-tier eligible type (t2.micro or t3.micro)."
  }
}

# AWS EC2 AMI ID
variable "aws_ami" {
  description = "AWS AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0f8a61b66d1accaee"
}

