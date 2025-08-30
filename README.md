# Nomad Testing Environment

This Terraform configuration creates 6 EC2 instances running CentOS Stream (latest available), suitable for testing HashiCorp Nomad, along with the necessary networking and security configurations.

## Architecture

- **6 EC2 instances** (t3.medium by default) running CentOS Stream
  - First 3 instances: Designed to be Nomad servers
  - Last 3 instances: Designed to be Nomad clients
- **Security Group** with ports opened for:
  - SSH (22)
  - Nomad HTTP API (4646)
  - Nomad RPC (4647)
  - Nomad Serf/Gossip (4648)
  - Consul ports (8300, 8301, 8500)
- **SSH Key Pair** generated automatically
- **Clean CentOS Stream instances** ready for manual Nomad installation and configuration

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **AWS permissions** to create EC2 instances, security groups, and key pairs

## Quick Start

1. **Clone and navigate to the terraform directory**
   ```bash
   cd /Users/jackharter/Developer/nomad_lab/terraform
   ```

2. **Copy and customize the variables file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred settings
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan the deployment**
   ```bash
   terraform plan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply
   ```

6. **Access your instances**
   - The private key will be saved as `nomad-testing-key.pem`
   - SSH to instances using: `ssh -i nomad-testing-key.pem ec2-user@<public-ip>`

## After Deployment

The instances will be clean CentOS Stream installations. You'll need to manually:

1. **Install Nomad** on all instances
2. **Install Consul** (optional, for service discovery)
3. **Install Docker** (for running containerized workloads)
4. **Configure Nomad servers** (first 3 instances)
5. **Configure Nomad clients** (last 3 instances)
6. **Start the Nomad services**

This manual process is great for learning how Nomad works under the hood!

## Customization

Edit `terraform.tfvars` to customize:
- `aws_region`: AWS region for deployment
- `instance_type`: EC2 instance size
- `instance_count`: Number of instances (default: 6)
- `allowed_ssh_cidr`: IP range allowed to SSH

## Security Notes

- The default configuration allows SSH from anywhere (`0.0.0.0/0`)
- For production use, restrict `allowed_ssh_cidr` to your IP range
- The private key is stored locally - keep it secure

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Costs

Approximate AWS costs (us-west-2):
- 6 x t3.medium instances: ~$0.0416/hour each = ~$0.25/hour total
- EBS storage: ~$0.10/GB/month for 20GB per instance
- Data transfer: Varies based on usage

## Troubleshooting

- Check AWS credentials: `aws sts get-caller-identity`
- Verify Terraform version: `terraform version`
- Check instance logs: `ssh -i nomad-testing-key.pem ec2-user@<ip> 'sudo tail -f /var/log/cloud-init-output.log'`
