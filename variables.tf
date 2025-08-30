# Variables for Nomad testing environment

variable "aws_region" {
  description = "AWS region for the Nomad testing environment"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type for Nomad nodes"
  type        = string
  default     = "t3.medium"
  # t3.medium provides 2 vCPUs and 4GB RAM, suitable for Nomad testing
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 6
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to the instances"
  type        = string
  default     = "0.0.0.0/0"
  # Note: For production, restrict this to your specific IP range
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "nomad-testing"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "testing"
}
