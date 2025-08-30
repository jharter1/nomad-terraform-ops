#!/bin/bash
# Quick deployment script for Nomad testing environment

set -e

echo "🚀 Nomad Testing Environment Deployment Script"
echo "=============================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ AWS CLI is not configured or credentials are invalid"
    echo "Please run 'aws configure' first"
    exit 1
fi

echo "✅ AWS credentials verified"

# Get current public IP for better security
echo "🔍 Detecting your public IPv4 address..."
PUBLIC_IP=$(curl -s -4 https://ipinfo.io/ip)
if [ -z "$PUBLIC_IP" ]; then
    echo "⚠️  Could not detect public IPv4, trying alternative service..."
    PUBLIC_IP=$(curl -s -4 https://ifconfig.me)
fi

# Validate that we got an IPv4 address (basic format check)
if [[ $PUBLIC_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    PUBLIC_IP_CIDR="$PUBLIC_IP/32"
    echo "✅ Detected public IPv4: $PUBLIC_IP"
else
    echo "❌ Could not detect a valid public IPv4 address"
    echo "You may need to manually set allowed_ssh_cidr in terraform.tfvars"
    PUBLIC_IP_CIDR="0.0.0.0/0"
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
fi

# Update the SSH CIDR in terraform.tfvars with detected IP
if [ "$PUBLIC_IP_CIDR" != "0.0.0.0/0" ]; then
    echo "🔒 Updating SSH access to your IP only: $PUBLIC_IP_CIDR"
    sed -i.bak "s|allowed_ssh_cidr = \".*\".*|allowed_ssh_cidr = \"$PUBLIC_IP_CIDR\"|" terraform.tfvars
    rm -f terraform.tfvars.bak
else
    echo "⚠️  Could not detect IP, setting open access with security warning"
    sed -i.bak "s|allowed_ssh_cidr = \".*\".*|allowed_ssh_cidr = \"0.0.0.0/0\"  # Change this to your IP for better security|" terraform.tfvars
    rm -f terraform.tfvars.bak
fi

# Show current configuration
echo ""
echo "📋 Current Configuration:"
echo "========================"
cat terraform.tfvars
echo ""

read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

echo "🔧 Running terraform plan..."
terraform plan -out=tfplan

read -p "Apply this plan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    rm -f tfplan
    exit 1
fi

echo "🚀 Deploying infrastructure..."
terraform apply tfplan

# Clean up the plan file after successful apply
rm -f tfplan

echo ""
echo "🎉 Deployment Complete!"
echo "======================"

# Show outputs
terraform output

echo ""
echo "📝 Next Steps:"
echo "1. Connect to your instances using the SSH commands above (username: ec2-user)"
echo "2. Manually install Nomad, Consul, and Docker on all instances"
echo "3. Configure Nomad on the server nodes (first 3 instances)"
echo "4. Configure Nomad on the client nodes (last 3 instances)"
echo "5. Start the Nomad services"
echo ""
echo "💡 The private key has been saved to: nomad-testing-key.pem"
echo "🐧 Instances are running CentOS Stream - perfect for learning Nomad manually!"
if [ "$PUBLIC_IP_CIDR" != "0.0.0.0/0" ]; then
    echo "🔒 SSH access is restricted to your IP: $PUBLIC_IP_CIDR"
else
    echo "⚠️  SSH access is open to all IPs (0.0.0.0/0) - consider restricting this"
fi
echo "💰 Remember to run 'terraform destroy' when done to avoid charges"
