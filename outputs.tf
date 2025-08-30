# Output values for the Nomad testing environment

output "instance_public_ips" {
  description = "Public IP addresses of the Nomad instances"
  value       = aws_instance.nomad_nodes[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of the Nomad instances"
  value       = aws_instance.nomad_nodes[*].private_ip
}

output "instance_ids" {
  description = "Instance IDs of the Nomad nodes"
  value       = aws_instance.nomad_nodes[*].id
}

output "ssh_key_path" {
  description = "Path to the private SSH key file"
  value       = local_file.nomad_private_key_pem.filename
}

output "ssh_command_examples" {
  description = "Example SSH commands to connect to the instances"
  value = [
    for i, ip in aws_instance.nomad_nodes[*].public_ip :
    "ssh -i ${local_file.nomad_private_key_pem.filename} ec2-user@${ip} # Node ${i + 1}"
  ]
}

output "centos_ami_info" {
  description = "Information about the CentOS Stream AMI being used"
  value = {
    id          = data.aws_ami.centos_stream8.id
    name        = data.aws_ami.centos_stream8.name
    description = data.aws_ami.centos_stream8.description
  }
}

output "nomad_ui_urls" {
  description = "URLs to access Nomad UI (once Nomad is configured and running)"
  value = [
    for i, ip in aws_instance.nomad_nodes[*].public_ip :
    "http://${ip}:4646" if i < 3 # Only server nodes will have UI
  ]
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.nomad_sg.id
}

output "key_pair_name" {
  description = "Name of the AWS key pair"
  value       = aws_key_pair.nomad_key.key_name
}
