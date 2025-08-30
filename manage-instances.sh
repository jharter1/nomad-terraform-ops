#!/bin/bash

# Script to start/stop all Nomad cluster instances
# Usage: ./manage-instances.sh [start|stop|status]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get instance IDs from Terraform output
get_instance_ids() {
    terraform output -json instance_ids | jq -r '.[]'
}

# Function to display usage
usage() {
    echo "Usage: $0 [start|stop|status]"
    echo ""
    echo "Commands:"
    echo "  start   - Start all stopped instances"
    echo "  stop    - Stop all running instances"
    echo "  status  - Show current status of all instances"
    echo ""
    exit 1
}

# Function to get instance status
get_status() {
    local instance_ids=("$@")
    echo -e "${YELLOW}Instance Status:${NC}"
    aws ec2 describe-instances \
        --region us-west-2 \
        --instance-ids "${instance_ids[@]}" \
        --output table \
        --query 'Reservations[].Instances[].[InstanceId,State.Name]'
}

# Function to start instances
start_instances() {
    local instance_ids=("$@")
    echo -e "${YELLOW}Starting instances...${NC}"
    aws ec2 start-instances --region us-west-2 --instance-ids "${instance_ids[@]}"
    echo -e "${GREEN}Start command sent. Instances will take a few moments to boot.${NC}"
}

# Function to stop instances
stop_instances() {
    local instance_ids=("$@")
    echo -e "${YELLOW}Stopping instances...${NC}"
    aws ec2 stop-instances --region us-west-2 --instance-ids "${instance_ids[@]}"
    echo -e "${GREEN}Stop command sent. Instances will take a few moments to shutdown.${NC}"
}

# Main script
main() {
    # Check if we're in the right directory
    if [ ! -f "terraform.tfstate" ]; then
        echo -e "${RED}Error: terraform.tfstate not found. Run this script from the terraform directory.${NC}"
        exit 1
    fi

    # Get instance IDs
    echo "Getting instance IDs from Terraform state..."
    INSTANCE_IDS=()
    while IFS= read -r line; do
        INSTANCE_IDS+=("$line")
    done < <(get_instance_ids)
    
    if [ ${#INSTANCE_IDS[@]} -eq 0 ]; then
        echo -e "${RED}Error: No instance IDs found in Terraform output${NC}"
        exit 1
    fi

    echo "Found instances: ${INSTANCE_IDS[*]}"
    echo ""

    # Parse command
    case "${1:-}" in
        "start")
            start_instances "${INSTANCE_IDS[@]}"
            echo ""
            echo "Waiting 30 seconds before showing status..."
            sleep 30
            get_status "${INSTANCE_IDS[@]}"
            ;;
        "stop")
            stop_instances "${INSTANCE_IDS[@]}"
            echo ""
            echo "Waiting 30 seconds before showing status..."
            sleep 30
            get_status "${INSTANCE_IDS[@]}"
            ;;
        "status")
            get_status "${INSTANCE_IDS[@]}"
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
