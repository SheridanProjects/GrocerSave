#!/bin/bash

# ==========================================
# GROCERSAVE DEPLOYMENT SCRIPT
# ==========================================
# Usage: ./deploy-grocersave.sh [all|shutdown|frontend|bff|auth|catalog|price|nginx|platform]

NAMESPACE="grocersave-dev"
CLUSTER_NAME="grocersave-cluster"
VPC_NAME="grocersave-vpc"
PROJECT_NAME="grocersave"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ==========================================
# 1. INITIALIZATION & INFRASTRUCTURE
# ==========================================
init_env() {
    # Check prerequisites
    for CMD in awslocal docker kubectl; do
        if ! command -v $CMD &> /dev/null; then
            echo -e "${RED}Error: $CMD is not installed.${NC}"
            exit 1
        fi
    done

    # LocalStack Dummy Creds
    export AWS_ACCESS_KEY_ID="test"
    export AWS_SECRET_ACCESS_KEY="test"
    export AWS_DEFAULT_REGION="us-east-1"

    setup_network
    check_k8s

    if ! kubectl get namespace $NAMESPACE > /dev/null 2>&1; then
        kubectl create namespace $NAMESPACE
    fi
}

setup_network() {
    echo "Checking Network Infrastructure..."

    # 1. VPC
    VPC_ID=$(awslocal ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[0].VpcId" --output text)

    if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
        echo "  Creating VPC ($VPC_NAME)..."
        VPC_ID=$(awslocal ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
        awslocal ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME

        # IGW
        IGW_ID=$(awslocal ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
        awslocal ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

        # Route Table
        RT_ID=$(awslocal ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
        awslocal ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID > /dev/null
    else
        echo "  Using existing VPC: $VPC_ID ($VPC_NAME)"
    fi

    # 2. Subnets
    SUBNET_ID=$(awslocal ec2 describe-subnets --filters "Name=tag:Name,Values=$PROJECT_NAME-public-subnet" "Name=vpc-id,Values=$VPC_ID" --query "Subnets[0].SubnetId" --output text)

    if [ "$SUBNET_ID" == "None" ] || [ -z "$SUBNET_ID" ]; then
        echo "  Creating Subnet..."
        SUBNET_ID=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)
        awslocal ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=$PROJECT_NAME-public-subnet

        # Route Table Association
        RT_ID=$(awslocal ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[0].RouteTableId" --output text)
        if [ "$RT_ID" != "None" ]; then
             awslocal ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID > /dev/null 2>&1
        fi
    else
        echo "  Using existing Subnet: $SUBNET_ID"
    fi

    # 3. Security Group
    SG_ID=$(awslocal ec2 describe-security-groups --filters "Name=group-name,Values=$PROJECT_NAME-sg" "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text)

    if [ "$SG_ID" == "None" ] || [ -z "$SG_ID" ]; then
        echo "  Creating Security Group..."
        SG_ID=$(awslocal ec2 create-security-group --group-name $PROJECT_NAME-sg --description "$PROJECT_NAME SG" --vpc-id $VPC_ID --query 'GroupId' --output text)
        # Allow standard ports
        for PORT in 80 443 3100 8180 8181 8182; do
            awslocal ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port $PORT --cidr 0.0.0.0/0 > /dev/null
        done
    else
        echo "  Using existing Security Group: $SG_ID"
    fi

    export APP_SUBNET_ID=$SUBNET_ID
    export APP_SG_ID=$SG_ID
}

check_k8s() {
    echo "Checking Kubernetes connection..."

    CLUSTER_STATUS=$(awslocal eks describe-cluster --name $CLUSTER_NAME --query "cluster.status" --output text 2>/dev/null)

    if [ "$CLUSTER_STATUS" == "ACTIVE" ] || [ "$CLUSTER_STATUS" == "CREATING" ]; then
        echo -e "${GREEN}Found existing $CLUSTER_NAME.${NC}"
    else
        echo -e "${YELLOW}$CLUSTER_NAME not found. Creating it...${NC}"
        awslocal eks create-cluster \
            --name $CLUSTER_NAME \
            --role-arn arn:aws:iam::000000000000:role/eks-role \
            --resources-vpc-config subnetIds=$APP_SUBNET_ID,securityGroupIds=$APP_SG_ID > /dev/null

        echo "  Cluster created. Waiting 60s for registration..."
        sleep 60
    fi

    # Check for Node Group
    NODE_GROUPS=$(awslocal eks list-nodegroups --cluster-name $CLUSTER_NAME --query 'nodegroups[0]' --output text)

    if [ "$NODE_GROUPS" == "None" ] || [ -z "$NODE_GROUPS" ]; then
        echo -e "${YELLOW}Creating node group...${NC}"
        awslocal eks create-nodegroup \
            --cluster-name $CLUSTER_NAME \
            --nodegroup-name $PROJECT_NAME-workers \
            --subnets $APP_SUBNET_ID \
            --node-role arn:aws:iam::000000000000:role/eks-node-role \
            --scaling-config minSize=1,maxSize=2,desiredSize=1 > /dev/null
    fi

    echo -e "${YELLOW}Configuring kubectl...${NC}"
    awslocal eks update-kubeconfig --name "$CLUSTER_NAME"

    if ! kubectl get nodes > /dev/null 2>&1; then
         echo -e "${RED}Failed to connect to K8s.${NC}"
         exit 1
    fi

    # Allow pods to run on the control-plane node for local development
    echo -e "${YELLOW}Untainting control-plane node...${NC}"
    kubectl taint nodes --all node-role.kubernetes.io/control-plane- > /dev/null 2>&1 || true
}

# ==========================================
# 2. DEPLOY FUNCTIONS
# ==========================================
deploy_service() {
    SERVICE_NAME=$1
    echo -e "\n${YELLOW}>>> Deploying $SERVICE_NAME...${NC}"

    REPO_NAME="grocersave-$SERVICE_NAME"
    ECR_ROOT="000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566"

    # Ensure ECR Repo
    awslocal ecr describe-repositories --repository-names "$REPO_NAME" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        awslocal ecr create-repository --repository-name "$REPO_NAME" > /dev/null
    fi

    # Login
    awslocal ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_ROOT" > /dev/null 2>&1

    # Determine Dockerfile & Build Context
    DOCKERFILE="$PROJECT_ROOT/Services/Dockerfile.backend"
    BUILD_ARG_NAME=$SERVICE_NAME

    # Specific Dockerfile logic
    if [ "$SERVICE_NAME" == "frontend" ]; then
        DOCKERFILE="$PROJECT_ROOT/Services/Dockerfile.frontend"
    elif [ "$SERVICE_NAME" == "bff-service" ]; then
        DOCKERFILE="$PROJECT_ROOT/Services/Dockerfile.bff"
    fi

    echo "  Building Image..."
    # Build image and check for failure
    if ! docker build -t "$REPO_NAME:latest" -f "$DOCKERFILE" --build-arg SERVICE_NAME=$BUILD_ARG_NAME "$PROJECT_ROOT"; then
        echo -e "${RED}Build failed for $SERVICE_NAME${NC}"
        exit 1
    fi

    FULL_TAG="$ECR_ROOT/$REPO_NAME:latest"
    docker tag "$REPO_NAME:latest" "$FULL_TAG"
    docker push "$FULL_TAG"

    echo -e "${GREEN}  Image pushed: $FULL_TAG${NC}"
}

deploy_single() {
    APP_NAME=$1
    MANIFEST=$2
    BUILD_SERVICE=$3

    # Only init env, do NOT re-apply namespace or platform unless needed
    # This prevents accidental overwrites or context switching issues

    # Check prerequisites
    for CMD in awslocal docker kubectl; do
        if ! command -v $CMD &> /dev/null; then
            echo -e "${RED}Error: $CMD is not installed.${NC}"
            exit 1
        fi
    done

    # Ensure we are targeting the correct cluster context
    # We do NOT run update-kubeconfig here to avoid switching context if the user is already set up
    # However, for safety in CI/CD or fresh terminals, we check if the context exists first

    CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null)
    EXPECTED_CONTEXT="arn:aws:eks:us-east-1:000000000000:cluster/$CLUSTER_NAME"

    if [ "$CURRENT_CONTEXT" != "$EXPECTED_CONTEXT" ]; then
         echo -e "${YELLOW}Switching context to $CLUSTER_NAME...${NC}"
         awslocal eks update-kubeconfig --name "$CLUSTER_NAME" > /dev/null 2>&1
    fi

    if [ -n "$BUILD_SERVICE" ]; then
        deploy_service "$BUILD_SERVICE"
    fi

    ECR_ROOT="000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566"

    echo -e "\n${YELLOW}>>> Applying $MANIFEST...${NC}"
    sed "s|image: grocersave/|image: $ECR_ROOT/grocersave-|g" "$SCRIPT_DIR/$MANIFEST" > "$SCRIPT_DIR/$MANIFEST.gen.yaml"
    kubectl apply -f "$SCRIPT_DIR/$MANIFEST.gen.yaml"
    rm "$SCRIPT_DIR/$MANIFEST.gen.yaml"

    echo -e "${YELLOW}>>> Restarting $APP_NAME...${NC}"
    if kubectl get deployment $APP_NAME -n $NAMESPACE > /dev/null 2>&1; then
        kubectl rollout restart deployment/$APP_NAME -n $NAMESPACE
    else
         echo -e "${YELLOW}Deployment $APP_NAME created.${NC}"
    fi

    # Show status of all pods in the current namespace to confirm visibility
    echo -e "\n${GREEN}>>> Current Pods in $NAMESPACE:${NC}"
    kubectl get pods -n $NAMESPACE
}

deploy_all() {
    init_env

    # 1. Deploy Platform (DBs)
    echo -e "\n${YELLOW}>>> Deploying Platform...${NC}"

    # Apply Namespace first
    kubectl apply -f "$SCRIPT_DIR/k8s-namespace.yaml"

    # List of platform manifests
    PLATFORM_MANIFESTS=("k8s-redis.yaml" "k8s-postgres.yaml" "k8s-rabbitmq.yaml" "k8s-cassandra.yaml" "k8s-elasticsearch.yaml")

    for MANIFEST in "${PLATFORM_MANIFESTS[@]}"; do
        kubectl apply -f "$SCRIPT_DIR/$MANIFEST"
    done

    echo "  Waiting 10s for platform services to initialize..."
    sleep 10

    # 2. Build & Push Apps
    deploy_service "auth-service"
    deploy_service "catalog-service"
    deploy_service "price-service"
    deploy_service "bff-service"
    deploy_service "frontend"

    # 3. Apply App Manifests
    # We update the manifest to point to the localstack ECR images dynamically
    ECR_ROOT="000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566"

    echo -e "\n${YELLOW}>>> Applying Kubernetes Manifests...${NC}"

    # List of app manifests to apply
    APP_MANIFESTS=("k8s-nginx.yaml" "k8s-frontend.yaml" "k8s-bff.yaml" "k8s-auth.yaml" "k8s-catalog.yaml" "k8s-price.yaml")

    for MANIFEST in "${APP_MANIFESTS[@]}"; do
        # Use a temp file to inject the ECR Root URL into the YAML
        sed "s|image: grocersave/|image: $ECR_ROOT/grocersave-|g" "$SCRIPT_DIR/$MANIFEST" > "$SCRIPT_DIR/$MANIFEST.gen.yaml"
        kubectl apply -f "$SCRIPT_DIR/$MANIFEST.gen.yaml"
        rm "$SCRIPT_DIR/$MANIFEST.gen.yaml"
    done

    # Restart ONLY application deployments to pick up new images
    # We avoid restarting DBs to preserve ephemeral data during dev sessions
    echo -e "${YELLOW}>>> Restarting Applications...${NC}"
    APPS=("nginx-proxy" "frontend" "bff-service" "auth-service" "catalog-service" "price-service")
    for APP in "${APPS[@]}"; do
        # Check if deployment exists before restarting
        if kubectl get deployment $APP -n $NAMESPACE > /dev/null 2>&1; then
            kubectl rollout restart deployment/$APP -n $NAMESPACE
        else
            echo -e "${RED}Warning: Deployment $APP not found. Skipping restart.${NC}"
        fi
    done

    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN} GROCERSAVE DEPLOYED ${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "App (via Nginx): http://localhost:31000 (NodePort)"
    echo -e "Or Port-Forward: kubectl port-forward -n $NAMESPACE svc/nginx-proxy 8080:80"
    echo -e "Then access: http://localhost:8080"
}

case "$1" in
    all)
        deploy_all
        ;;
    frontend)
        deploy_single "frontend" "k8s-frontend.yaml" "frontend"
        ;;
    bff)
        deploy_single "bff-service" "k8s-bff.yaml" "bff-service"
        ;;
    auth)
        deploy_single "auth-service" "k8s-auth.yaml" "auth-service"
        ;;
    catalog)
        deploy_single "catalog-service" "k8s-catalog.yaml" "catalog-service"
        ;;
    price)
        deploy_single "price-service" "k8s-price.yaml" "price-service"
        ;;
    nginx)
        deploy_single "nginx-proxy" "k8s-nginx.yaml" ""
        ;;
    platform)
        init_env
        echo -e "\n${YELLOW}>>> Deploying Platform...${NC}"
        kubectl apply -f "$SCRIPT_DIR/k8s-namespace.yaml"
        PLATFORM_MANIFESTS=("k8s-redis.yaml" "k8s-postgres.yaml" "k8s-rabbitmq.yaml" "k8s-cassandra.yaml" "k8s-elasticsearch.yaml")
        for MANIFEST in "${PLATFORM_MANIFESTS[@]}"; do
            kubectl apply -f "$SCRIPT_DIR/$MANIFEST"
        done
        ;;
    shutdown)
        echo -e "${YELLOW}Shutting down GrocerSave...${NC}"

        # Delete app manifests
        APP_MANIFESTS=("k8s-nginx.yaml" "k8s-frontend.yaml" "k8s-bff.yaml" "k8s-auth.yaml" "k8s-catalog.yaml" "k8s-price.yaml")
        for MANIFEST in "${APP_MANIFESTS[@]}"; do
            kubectl delete -f "$SCRIPT_DIR/$MANIFEST" --ignore-not-found
        done

        # Delete platform manifests
        PLATFORM_MANIFESTS=("k8s-redis.yaml" "k8s-postgres.yaml" "k8s-rabbitmq.yaml" "k8s-cassandra.yaml" "k8s-elasticsearch.yaml")
        for MANIFEST in "${PLATFORM_MANIFESTS[@]}"; do
            kubectl delete -f "$SCRIPT_DIR/$MANIFEST" --ignore-not-found
        done

        # Delete namespace
        kubectl delete -f "$SCRIPT_DIR/k8s-namespace.yaml" --ignore-not-found
        ;;
    *)
        echo "Usage: ./deploy-grocersave.sh [all|shutdown|frontend|bff|auth|catalog|price|nginx|platform]"
        ;;
esac

# testing PR for the project report :)