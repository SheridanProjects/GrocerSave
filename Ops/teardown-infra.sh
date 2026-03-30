#!/bin/bash

# ==========================================
# GROCERSAVE INFRASTRUCTURE TEARDOWN SCRIPT
# ==========================================
# This script completely removes the network and EKS infrastructure
# created by the deploy-grocersave.sh script.

VPC_NAME="grocersave-vpc"
CLUSTER_NAME="grocersave-cluster"
PROJECT_NAME="grocersave"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Define SCRIPT_DIR so the kubeconfig cleanup at the end actually works
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${YELLOW}>>> Starting GrocerSave Infrastructure Teardown...${NC}"

# Set dummy creds for LocalStack
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

# ==========================================
# WRAPPER FUNCTION: Replaces awslocal
# ==========================================
local_aws() {
    aws --endpoint-url=http://localhost:4566 "$@"
}

# 1. Delete the EKS Cluster and Node Group first
echo -e "\n${YELLOW}--- Step 1: Deleting EKS Cluster and Node Group ---${NC}"
if local_aws eks describe-cluster --name "$CLUSTER_NAME" > /dev/null 2>&1; then
    echo "  Deleting Node Group '$PROJECT_NAME-workers'..."
    local_aws eks delete-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$PROJECT_NAME-workers" > /dev/null 2>&1

    echo "  Waiting for Node Group to be deleted..."
    local_aws eks wait nodegroup-deleted --cluster-name "$CLUSTER_NAME" --nodegroup-name "$PROJECT_NAME-workers"

    echo "  Deleting EKS Cluster '$CLUSTER_NAME'..."
    local_aws eks delete-cluster --name "$CLUSTER_NAME" > /dev/null 2>&1

    echo "  Waiting for EKS Cluster to be deleted..."
    local_aws eks wait cluster-deleted --name "$CLUSTER_NAME"
    echo -e "${GREEN}  EKS Cluster deleted successfully.${NC}"
else
    echo -e "${GREEN}  EKS Cluster '$CLUSTER_NAME' not found. Skipping.${NC}"
fi

# 2. Find VPC and its components
echo -e "\n${YELLOW}--- Step 2: Deleting Network Infrastructure ---${NC}"
VPC_ID=$(local_aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[0].VpcId" --output text 2>/dev/null)

if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
    echo -e "${GREEN}  VPC '$VPC_NAME' not found. Nothing to do.${NC}"
    # Ensure kubeconfig is still cleaned up even if VPC was already gone
    rm -f "$SCRIPT_DIR/.kubeconfig-localstack"
    exit 0
fi

echo "  Found VPC: $VPC_ID"

# 3. Detach and Delete Internet Gateway
IGW_ID=$(local_aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[0].InternetGatewayId" --output text 2>/dev/null)
if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
    echo "  Detaching and deleting Internet Gateway: $IGW_ID"
    local_aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
    local_aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"
fi

# 4. Delete Subnets
SUBNET_IDS=$(local_aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text)
if [ -n "$SUBNET_IDS" ]; then
    for SUBNET_ID in $SUBNET_IDS; do
        echo "  Deleting Subnet: $SUBNET_ID"
        local_aws ec2 delete-subnet --subnet-id "$SUBNET_ID"
    done
fi

# 5. Delete Security Groups
SG_IDS=$(local_aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
if [ -n "$SG_IDS" ]; then
    for SG_ID in $SG_IDS; do
        echo "  Deleting Security Group: $SG_ID"
        local_aws ec2 delete-security-group --group-id "$SG_ID"
    done
fi

# 6. Delete Route Tables
RT_IDS=$(local_aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?Associations[?Main!=true]].RouteTableId" --output text)
if [ -n "$RT_IDS" ]; then
    for RT_ID in $RT_IDS; do
        echo "  Deleting Route Table: $RT_ID"
        local_aws ec2 delete-route-table --route-table-id "$RT_ID"
    done
fi

# 7. Finally, delete the VPC
echo "  Deleting VPC: $VPC_ID"
local_aws ec2 delete-vpc --vpc-id "$VPC_ID"

# 8. Clean up the generated kubeconfig
rm -f "$SCRIPT_DIR/.kubeconfig-localstack"

echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN} ✅ Teardown Complete! ✅ ${NC}"
echo -e "${GREEN}==========================================${NC}"