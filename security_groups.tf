# Security group for Nomad cluster instances

resource "aws_security_group" "nomad_sg" {
  name        = "${var.project_name}-security-group"
  description = "Security group for Nomad testing cluster"

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Nomad HTTP API
  ingress {
    description = "Nomad HTTP API"
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Nomad RPC
  ingress {
    description = "Nomad RPC"
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    self        = true
  }

  # Nomad Serf (gossip protocol)
  ingress {
    description = "Nomad Serf"
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Nomad Serf UDP"
    from_port   = 4648
    to_port     = 4648
    protocol    = "udp"
    self        = true
  }

  # Consul ports (if using Consul with Nomad)
  ingress {
    description = "Consul HTTP"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Consul RPC"
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Consul Serf LAN"
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Consul Serf LAN UDP"
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    self        = true
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-security-group"
    Environment = var.environment
    Purpose     = "nomad-cluster"
  }
}
