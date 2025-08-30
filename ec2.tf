# EC2 instances for Nomad cluster

resource "aws_instance" "nomad_nodes" {
  count                  = var.instance_count
  ami                    = data.aws_ami.centos_stream8.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.nomad_key.key_name
  vpc_security_group_ids = [aws_security_group.nomad_sg.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-node-${count.index + 1}"
    Environment = var.environment
    Purpose     = "nomad-cluster"
    NodeIndex   = count.index
    # Tag to identify server vs client nodes (first 3 as servers, rest as clients)
    NodeType = count.index < 3 ? "server" : "client"
  }
}
