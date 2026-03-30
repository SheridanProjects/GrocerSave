#!/bin/bash

# ==========================================
# GROCERSAVE PORT FORWARDING SCRIPT
# ==========================================
# Usage: ./port-forward-grocersave.sh

NAMESPACE="grocersave-dev"
CLUSTER_NAME="grocersave-cluster"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ISOLATE KUBECONFIG: Automatically point kubectl to LocalStack
export KUBECONFIG="$SCRIPT_DIR/.kubeconfig-localstack"

# ==========================================
# WRAPPER FUNCTION: Replaces awslocal
# ==========================================
local_aws() {
    aws --endpoint-url=http://localhost:4566 "$@"
}

# Set dummy creds for LocalStack CLI calls
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

# Ensure we have the kubeconfig before trying to port-forward
if [ ! -f "$KUBECONFIG" ]; then
     echo -e "${YELLOW}Isolated Kubeconfig not found. Attempting to fetch it from LocalStack...${NC}"
     local_aws eks update-kubeconfig --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG" > /dev/null 2>&1
     if [ ! -f "$KUBECONFIG" ]; then
         echo -e "${RED}Error: Failed to fetch kubeconfig. Is the cluster running? Run the deploy script first.${NC}"
         exit 1
     fi
fi

echo -e "${GREEN}Starting Port Forwarding for GrocerSave Services...${NC}"
echo "Press Ctrl+C to stop all forwards."
echo ""

# Function to kill background jobs on exit
cleanup() {
    echo -e "\n${YELLOW}Stopping all port forwards...${NC}"
    kill $(jobs -p) 2>/dev/null
    exit
}
trap cleanup SIGINT

# Main App Entry Point (via Frontend's internal proxy)
echo -e "${GREEN}GrocerSave App:${NC} http://localhost:8091"
kubectl port-forward --address 0.0.0.0 -n $NAMESPACE svc/frontend 8091:5000 > /dev/null 2>&1 &

# Main Nginx Proxy (alternative entry point for debugging)
echo -e "${YELLOW}Nginx Proxy (Debug):${NC} http://localhost:8090"
kubectl port-forward --address 0.0.0.0 -n $NAMESPACE svc/nginx-proxy 8090:80 > /dev/null 2>&1 &

# Direct access to services for debugging
echo -e "${YELLOW}BFF Service (Debug):${NC} http://localhost:3100"
kubectl port-forward -n $NAMESPACE svc/bff-service 3100:3100 > /dev/null 2>&1 &

echo -e "${YELLOW}Auth Service (Debug):${NC} http://localhost:8180"
kubectl port-forward -n $NAMESPACE svc/auth-service 8180:8180 > /dev/null 2>&1 &

echo -e "${YELLOW}Catalog Svc (Debug):${NC} http://localhost:8181"
kubectl port-forward -n $NAMESPACE svc/catalog-service 8181:8181 > /dev/null 2>&1 &

echo -e "${YELLOW}Price Service (Debug):${NC} http://localhost:8182"
kubectl port-forward -n $NAMESPACE svc/price-service 8182:8182 > /dev/null 2>&1 &

echo -e "${YELLOW}RabbitMQ UI (Debug):${NC} http://localhost:15673 (user/password)"
kubectl port-forward -n $NAMESPACE svc/rabbitmq 15673:15672 > /dev/null 2>&1 &

# Keep script running
wait