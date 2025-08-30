#!/bin/bash
# User data script for Nomad testing instances

# Update the system
yum update -y

# Install essential packages
yum install -y wget unzip curl docker

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Create nomad user
useradd nomad
usermod -a -G docker nomad

# Create directories for Nomad
mkdir -p /opt/nomad
mkdir -p /etc/nomad.d
mkdir -p /var/lib/nomad

# Download and install Nomad (latest version)
cd /tmp || exit
wget https://releases.hashicorp.com/nomad/1.6.1/nomad_1.6.1_linux_amd64.zip
unzip nomad_1.6.1_linux_amd64.zip
sudo mv nomad /usr/local/bin/
sudo chmod +x /usr/local/bin/nomad

# Set permissions
chown -R nomad:nomad /opt/nomad
chown -R nomad:nomad /etc/nomad.d
chown -R nomad:nomad /var/lib/nomad

# Create a basic nomad service file
cat > /etc/systemd/system/nomad.service << EOF
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/nomad.d/nomad.hcl

[Service]
Type=notify
User=nomad
Group=nomad
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d/nomad.hcl
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Enable nomad service (but don't start it yet - needs configuration)
systemctl enable nomad

# Create a placeholder config file (to be configured later)
cat > /etc/nomad.d/nomad.hcl << EOF
# This is a placeholder configuration
# Node index: ${node_index}
# Configure this file based on whether this is a server or client node
EOF

# Install Consul (often used with Nomad)
cd /tmp || exit
wget https://releases.hashicorp.com/consul/1.16.1/consul_1.16.1_linux_amd64.zip
unzip consul_1.16.1_linux_amd64.zip
sudo mv consul /usr/local/bin/
sudo chmod +x /usr/local/bin/consul

# Create consul directories
mkdir -p /opt/consul
mkdir -p /etc/consul.d
mkdir -p /var/lib/consul

# Set consul permissions
chown -R nomad:nomad /opt/consul
chown -R nomad:nomad /etc/consul.d
chown -R nomad:nomad /var/lib/consul

echo "Instance initialization complete. Node index: ${node_index}"
