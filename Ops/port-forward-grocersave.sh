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

# Ensure we are on the right cluster
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null)
EXPECTED_CONTEXT="arn:aws:eks:us-east-1:000000000000:cluster/$CLUSTER_NAME"

if [ "$CURRENT_CONTEXT" != "$EXPECTED_CONTEXT" ]; then
     echo -e "${YELLOW}Switching context to $CLUSTER_NAME...${NC}"
     awslocal eks update-kubeconfig --name "$CLUSTER_NAME" > /dev/null 2>&1
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

# The ONLY entry point you need. This port works for the UI and all API calls.
echo -e "${GREEN}GrocerSave App:${NC} http://localhost:8091"
kubectl port-forward --address 0.0.0.0 -n $NAMESPACE svc/frontend 8091:80 > /dev/null 2>&1 &

# Optional: Direct access to BFF for debugging
echo -e "${YELLOW}BFF Service (Debug):${NC} http://localhost:3100"
kubectl port-forward -n $NAMESPACE svc/bff-service 3100:3100 > /dev/null 2>&1 &

# 5. Catalog Service
echo -e "${GREEN}Catalog Svc:${NC}  http://0.0.0.0:8181"
kubectl port-forward --address 0.0.0.0 -n $NAMESPACE svc/catalog-service 8181:8081 > /dev/null 2>&1 &

# 6. Price Service
echo -e "${GREEN}Price Service:${NC} http://0.0.0.0:8182"
kubectl port-forward --address 0.0.0.0 -n $NAMESPACE svc/price-service 8182:8082 > /dev/null 2>&1 &

# 7. RabbitMQ Management UI -> Changed to 15673 to avoid conflict
echo -e "${GREEN}RabbitMQ UI:${NC}   http://0.0.0.0:15673 (user/password)"
kubectl port-forward --address 0.0.0.0 -n $NAMESPACE svc/rabbitmq 15673:15672 > /dev/null 2>&1 &

# Keep script running
wait