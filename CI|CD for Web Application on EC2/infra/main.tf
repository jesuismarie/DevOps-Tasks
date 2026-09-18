# Define the AWS EC2 Instance
resource "aws_instance" "webapp" {
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name      = aws_key_pair.webapp.key_name

  tags = {
    Name        = "webapp"
    Description = "Webapp EC2 instance provisioned by Terraform"
  }

  vpc_security_group_ids = [aws_security_group.webapp.id]
}

# Define AWS EC2 Instance Key Pair
resource "aws_key_pair" "webapp" {
  key_name   = "webapp-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# Define The Security Group for the EC2 Instance
resource "aws_security_group" "webapp" {
  name        = "webapp-sg"
  description = "Security group for webapp instance"

  ingress {
    description = "Allow SSH (22)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Web Traffic (3000)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
