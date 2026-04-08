#!/bin/bash

# ==========================================
# GROCERSAVE DEPLOYMENT SCRIPT (ROBUST & VERBOSE)
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

# ISOLATE KUBECONFIG: Prevents messing with user's host kubeconfig and avoids context conflicts
export KUBECONFIG="$SCRIPT_DIR/.kubeconfig-localstack"

# ==========================================
# WRAPPER FUNCTION: Replaces awslocal
# ==========================================
local_aws() {
    aws --endpoint-url=http://localhost:4566 --region us-east-1 "$@"
}

# ==========================================
# 1. INITIALIZATION & INFRASTRUCTURE
# ==========================================
init_env() {
    # Check prerequisites (awslocal removed, aws added)
    for CMD in aws docker kubectl yq; do
        if ! command -v $CMD &> /dev/null; then
            echo -e "${RED}Error: $CMD is not installed. Please install it first.${NC}"
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
        echo -e "${YELLOW}Creating namespace $NAMESPACE...${NC}"
        kubectl create namespace $NAMESPACE
    fi
}

setup_network() {
    echo -e "\n${YELLOW}>>> Checking Network Infrastructure...${NC}"

    # 1. VPC
    VPC_ID=$(local_aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[0].VpcId" --output text 2>/dev/null)

    if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
        echo "  Creating VPC ($VPC_NAME)..."
        VPC_ID=$(local_aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
        local_aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME

        # IGW
        IGW_ID=$(local_aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
        local_aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

        # Route Table
        RT_ID=$(local_aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
        local_aws ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID > /dev/null
    else
        echo "  Using existing VPC: $VPC_ID ($VPC_NAME)"
    fi

    # 2. Subnets (AWS EKS REQUIRES at least 2 subnets in different Availability Zones)
    SUBNET_CIDR_1="10.0.1.0/24"
    SUBNET_CIDR_2="10.0.2.0/24"
    AZ_1="us-east-1a"
    AZ_2="us-east-1b"

    # Subnet 1
    SUBNET_ID_1=$(local_aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=cidr-block,Values=$SUBNET_CIDR_1" --query "Subnets[0].SubnetId" --output text 2>/dev/null)
    if [ "$SUBNET_ID_1" == "None" ] || [ -z "$SUBNET_ID_1" ]; then
        echo "  Creating Subnet 1 ($SUBNET_CIDR_1 in $AZ_1)..."
        SUBNET_ID_1=$(local_aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR_1 --availability-zone $AZ_1 --query 'Subnet.SubnetId' --output text)
        local_aws ec2 create-tags --resources $SUBNET_ID_1 --tags Key=Name,Value=$PROJECT_NAME-public-subnet-1
    else
        echo "  Using existing Subnet 1: $SUBNET_ID_1"
    fi

    # Subnet 2
    SUBNET_ID_2=$(local_aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=cidr-block,Values=$SUBNET_CIDR_2" --query "Subnets[0].SubnetId" --output text 2>/dev/null)
    if [ "$SUBNET_ID_2" == "None" ] || [ -z "$SUBNET_ID_2" ]; then
        echo "  Creating Subnet 2 ($SUBNET_CIDR_2 in $AZ_2)..."
        SUBNET_ID_2=$(local_aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR_2 --availability-zone $AZ_2 --query 'Subnet.SubnetId' --output text)
        local_aws ec2 create-tags --resources $SUBNET_ID_2 --tags Key=Name,Value=$PROJECT_NAME-public-subnet-2
    else
        echo "  Using existing Subnet 2: $SUBNET_ID_2"
    fi

    # Associate Route Table with both subnets
    RT_ID=$(local_aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?Associations[?Main!=true]].RouteTableId" --output text)
    if [ "$RT_ID" != "None" ]; then
        local_aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID_1 > /dev/null 2>&1
        local_aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID_2 > /dev/null 2>&1
    fi

    # 3. Security Group
    SG_ID=$(local_aws ec2 describe-security-groups --filters "Name=group-name,Values=$PROJECT_NAME-sg" "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

    if [ "$SG_ID" == "None" ] || [ -z "$SG_ID" ]; then
        echo "  Creating Security Group..."
        SG_ID=$(local_aws ec2 create-security-group --group-name $PROJECT_NAME-sg --description "$PROJECT_NAME SG" --vpc-id $VPC_ID --query 'GroupId' --output text)
        for PORT in 80 443 3100 8180 8181 8182 5000; do
            local_aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port $PORT --cidr 0.0.0.0/0 > /dev/null
        done
    else
        echo "  Using existing Security Group: $SG_ID"
    fi

    # Export Both Subnets
    export APP_SUBNETS="$SUBNET_ID_1,$SUBNET_ID_2"
    export APP_SG_ID=$SG_ID
}

wait_for_k8s_api() {
    echo -n "  Waiting for Kubernetes API to respond reliably"
    local retries=30
    local count=0
    while [ $count -lt $retries ]; do
        if kubectl get nodes > /dev/null 2>&1; then
            echo -e "\n${GREEN}  Kubernetes API is ready!${NC}"
            return 0
        fi
        echo -n "."
        sleep 3
        count=$((count+1))
    done
    echo -e "\n${RED}Timeout waiting for Kubernetes API.${NC}"
    exit 1
}

check_k8s() {
    echo -e "\n${YELLOW}>>> Checking Kubernetes Cluster ($CLUSTER_NAME)...${NC}"

    # 1. Fetch cluster status
    CLUSTER_STATUS=$(local_aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.status" --output text 2>/dev/null)

    # Clean up broken/failed clusters automatically before proceeding
    if [ "$CLUSTER_STATUS" == "FAILED" ] || [ "$CLUSTER_STATUS" == "DELETING" ]; then
        echo -e "${RED}  Found cluster in $CLUSTER_STATUS state. Cleaning up...${NC}"
        local_aws eks delete-cluster --name "$CLUSTER_NAME" > /dev/null 2>&1 || true
        while local_aws eks describe-cluster --name "$CLUSTER_NAME" > /dev/null 2>&1; do
            echo "  Waiting for broken cluster to be fully deleted..."
            sleep 5
        done
        CLUSTER_STATUS="" # Reset status to trigger fresh creation
    fi

    if [ "$CLUSTER_STATUS" == "ACTIVE" ]; then
        echo -e "${GREEN}  Found existing ACTIVE cluster '$CLUSTER_NAME'.${NC}"
    elif [ "$CLUSTER_STATUS" == "CREATING" ]; then
        echo -e "${YELLOW}  Cluster '$CLUSTER_NAME' is currently CREATING...${NC}"
    else
        echo -e "${YELLOW}  Initiating cluster creation with required subnets in different AZs...${NC}"
        local_aws eks create-cluster \
            --name "$CLUSTER_NAME" \
            --role-arn arn:aws:iam::000000000000:role/eks-role \
            --resources-vpc-config subnetIds=$APP_SUBNETS,securityGroupIds=$APP_SG_ID > /dev/null
        sleep 5
    fi

    # 2. Wait loop for cluster to reach ACTIVE status
    CLUSTER_STATUS=$(local_aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.status" --output text 2>/dev/null)
    while [ "$CLUSTER_STATUS" != "ACTIVE" ]; do
        if [ "$CLUSTER_STATUS" == "None" ] || [ -z "$CLUSTER_STATUS" ]; then CLUSTER_STATUS="PENDING"; fi
        if [ "$CLUSTER_STATUS" == "FAILED" ]; then echo -e "${RED}  Cluster creation failed with status: FAILED${NC}"; exit 1; fi
        echo "  Status: $CLUSTER_STATUS. Waiting for ACTIVE..."
        sleep 10
        CLUSTER_STATUS=$(local_aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.status" --output text 2>/dev/null)
    done
    echo -e "${GREEN}  Cluster is now ACTIVE.${NC}"

    # 3. Ensure Node Group exists
    if ! local_aws eks describe-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$PROJECT_NAME-workers" > /dev/null 2>&1; then
        echo -e "${YELLOW}  Creating node group...${NC}"
        local_aws eks create-nodegroup \
            --cluster-name "$CLUSTER_NAME" \
            --nodegroup-name "$PROJECT_NAME-workers" \
            --subnets "$APP_SUBNETS" \
            --node-role arn:aws:iam::000000000000:role/eks-node-role \
            --scaling-config minSize=1,maxSize=2,desiredSize=1 > /dev/null
    fi

    # 4. Configure kubectl with retry and explicitly pass --kubeconfig flag
    echo -e "${YELLOW}  Configuring local kubectl context (retrying if necessary)...${NC}"
    local retries=10
    local count=0
    while [ $count -lt $retries ]; do
        echo "  Attempting to generate kubeconfig (Attempt $((count+1))/$retries)..."
        local_aws eks update-kubeconfig --name "$CLUSTER_NAME" --kubeconfig "$KUBECONFIG"
        if [ -f "$KUBECONFIG" ]; then
            echo -e "${GREEN}  Kubeconfig created successfully at $KUBECONFIG.${NC}"
            break
        fi
        echo "  Kubeconfig not ready yet, retrying in 10 seconds..."
        sleep 10
        count=$((count+1))
    done

    if [ ! -f "$KUBECONFIG" ]; then
        echo -e "${RED}  Failed to create kubeconfig after multiple retries. Please check the output above for errors.${NC}"
        exit 1
    fi

    # Wait until API is genuinely answering requests
    wait_for_k8s_api

    echo -e "${YELLOW}  Untainting control-plane node (for local dev)...${NC}"
    kubectl taint nodes --all node-role.kubernetes.io/control-plane- > /dev/null 2>&1 || true
}

# ==========================================
# 2. DEPLOY FUNCTIONS
# ==========================================
deploy_service() {
    SERVICE_NAME=$1
    echo -e "\n${YELLOW}>>> Deploying Service: $SERVICE_NAME...${NC}"

    REPO_NAME="grocersave-$SERVICE_NAME"
    ECR_ROOT="000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566"

    # Ensure ECR Repo
    if ! local_aws ecr describe-repositories --repository-names "$REPO_NAME" > /dev/null 2>&1; then
        local_aws ecr create-repository --repository-name "$REPO_NAME" > /dev/null
    fi

    # Login to local ECR
    local_aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_ROOT" > /dev/null 2>&1

    # Determine Dockerfile & Build Context safely
    DOCKERFILE="$PROJECT_ROOT/Services/Dockerfile.backend"
    BUILD_CONTEXT="$PROJECT_ROOT"
    BUILD_ARG_NAME=$SERVICE_NAME

    if [ "$SERVICE_NAME" == "frontend" ]; then
        DOCKERFILE="$PROJECT_ROOT/Frontend/Dockerfile"
        BUILD_CONTEXT="$PROJECT_ROOT/Frontend"
        BUILD_ARG_NAME=""
    elif [ "$SERVICE_NAME" == "bff-service" ]; then
        DOCKERFILE="$PROJECT_ROOT/Services/Dockerfile.bff"
    fi

    if [ ! -f "$DOCKERFILE" ]; then
        echo -e "${RED}Error: Dockerfile not found at $DOCKERFILE${NC}"
        exit 1
    fi

    echo "  Building Image..."
    if [ -n "$BUILD_ARG_NAME" ]; then
        if ! docker build -t "$REPO_NAME:latest" -f "$DOCKERFILE" --build-arg SERVICE_NAME=$BUILD_ARG_NAME "$BUILD_CONTEXT"; then
            echo -e "${RED}Build failed for $SERVICE_NAME${NC}"
            exit 1
        fi
    else
        if ! docker build -t "$REPO_NAME:latest" -f "$DOCKERFILE" "$BUILD_CONTEXT"; then
            echo -e "${RED}Build failed for $SERVICE_NAME${NC}"
            exit 1
        fi
    fi

    FULL_TAG="$ECR_ROOT/$REPO_NAME:latest"
    docker tag "$REPO_NAME:latest" "$FULL_TAG"
    docker push "$FULL_TAG" > /dev/null

    echo -e "${GREEN}  Image successfully built and pushed: $FULL_TAG${NC}"
}

deploy_single() {
    APP_NAME=$1
    MANIFEST=$2
    BUILD_SERVICE=$3

    export KUBECONFIG="$SCRIPT_DIR/.kubeconfig-localstack"

    if [ ! -f "$KUBECONFIG" ]; then
        echo -e "${YELLOW}Kubeconfig not found. Initializing environment...${NC}"
        init_env
    fi

    if [ -n "$BUILD_SERVICE" ]; then
        deploy_service "$BUILD_SERVICE"
    fi

    export ECR_ROOT="000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566"

    echo -e "\n${YELLOW}>>> Applying Manifest: $MANIFEST...${NC}"
    if [ ! -f "$SCRIPT_DIR/$MANIFEST" ]; then
         echo -e "${RED}Manifest file $MANIFEST not found in $SCRIPT_DIR.${NC}"
         exit 1
    fi

    sed "s|image: grocersave/|image: ${ECR_ROOT}/grocersave-|g" "$SCRIPT_DIR/$MANIFEST" | kubectl apply -f -

    echo -e "${YELLOW}>>> Restarting $APP_NAME...${NC}"
    if kubectl get deployment $APP_NAME -n $NAMESPACE > /dev/null 2>&1; then
        kubectl rollout restart deployment/$APP_NAME -n $NAMESPACE
    else
         echo -e "${GREEN}Deployment $APP_NAME created.${NC}"
    fi

    echo -e "\n${GREEN}>>> Current Pods in $NAMESPACE:${NC}"
    kubectl get pods -n $NAMESPACE
}

deploy_all() {
    init_env

    echo -e "\n${YELLOW}>>> Deploying Platform Services (Databases & Brokers)...${NC}"

    if [ -f "$SCRIPT_DIR/k8s-namespace.yaml" ]; then
        kubectl apply -f "$SCRIPT_DIR/k8s-namespace.yaml"
    fi

    echo "  Seeding Kubernetes Secrets..."
    kubectl create secret generic postgres-creds --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=postgres --from-literal=POSTGRES_DB=postgres -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret generic rabbitmq-creds --from-literal=RABBITMQ_DEFAULT_USER=guest --from-literal=RABBITMQ_DEFAULT_PASS=guest -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

    PLATFORM_MANIFESTS=("k8s-redis.yaml" "k8s-postgres.yaml" "k8s-rabbitmq.yaml" "k8s-cassandra.yaml" "k8s-elasticsearch.yaml")
    for MANIFEST in "${PLATFORM_MANIFESTS[@]}"; do
        if [ -f "$SCRIPT_DIR/$MANIFEST" ]; then
            kubectl apply -f "$SCRIPT_DIR/$MANIFEST"
        else
            echo -e "${RED}Warning: Platform manifest $MANIFEST not found. Skipping.${NC}"
        fi
    done

    echo -e "\n${YELLOW}  Waiting for platform services to be 'Ready' (This prevents app crash-loops)...${NC}"
    kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=120s >/dev/null 2>&1 || {
        echo -e "${YELLOW}  Some platform pods took too long, proceeding anyway (they may still be starting).${NC}"
    }

    echo -e "\n${YELLOW}>>> Deploying Logging Service (Fluent Bit)...${NC}"
    LOGGING_MANIFESTS=("k8s-fluent-bit-config.yaml" "k8s-fluent-bit-daemonset.yaml" "k8s-xray-config.yaml")
    for MANIFEST in "${LOGGING_MANIFESTS[@]}"; do
        if [ -f "$SCRIPT_DIR/$MANIFEST" ]; then
            kubectl apply -f "$SCRIPT_DIR/$MANIFEST"
        else
            echo -e "${RED}Warning: Logging manifest $MANIFEST not found. Skipping.${NC}"
        fi
    done

    echo -e "\n${YELLOW}>>> Deploying Security Monitoring (Falco)...${NC}"
    if [ -f "$SCRIPT_DIR/k8s-falco.yaml" ]; then
        kubectl apply -f "$SCRIPT_DIR/k8s-falco.yaml"
    fi

    echo -e "\n${YELLOW}>>> Building & Pushing Application Images...${NC}"
    deploy_service "auth-service"
    deploy_service "catalog-service"
    deploy_service "price-service"
    deploy_service "bff-service"
    deploy_service "frontend"

    echo -e "\n${YELLOW}>>> Applying Application Manifests...${NC}"
    export ECR_ROOT="000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566"
    APP_MANIFESTS=("k8s-nginx.yaml" "k8s-frontend.yaml" "k8s-bff.yaml" "k8s-auth.yaml" "k8s-catalog.yaml" "k8s-price.yaml")

    for MANIFEST in "${APP_MANIFESTS[@]}"; do
        if [ -f "$SCRIPT_DIR/$MANIFEST" ]; then
            sed "s|image: grocersave/|image: ${ECR_ROOT}/grocersave-|g" "$SCRIPT_DIR/$MANIFEST" | kubectl apply -f -
        else
            echo -e "${RED}Warning: App manifest $MANIFEST not found. Skipping.${NC}"
        fi
    done

    echo -e "\n${YELLOW}>>> Refreshing Deployments to catch new images...${NC}"
    APPS=("nginx-proxy" "frontend" "bff-service" "auth-service" "catalog-service" "price-service")
    for APP in "${APPS[@]}"; do
        if kubectl get deployment $APP -n $NAMESPACE > /dev/null 2>&1; then
            kubectl rollout restart deployment/$APP -n $NAMESPACE
        fi
    done

    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN} :) GROCERSAVE DEPLOYED SUCCESSFULLY (: ${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "Wait a few seconds for pods to spin up, then access the app:"
    echo -e "Please run prot-forward-grocersave.sh to forward the ports "
    echo -e "GrocerSave App: http://localhost:8091"
    echo -e "\nTo view pods:   KUBECONFIG=$KUBECONFIG kubectl get pods -n $NAMESPACE"
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
        if [ -f "$SCRIPT_DIR/k8s-namespace.yaml" ]; then kubectl apply -f "$SCRIPT_DIR/k8s-namespace.yaml"; fi
        PLATFORM_MANIFESTS=("k8s-redis.yaml" "k8s-postgres.yaml" "k8s-rabbitmq.yaml" "k8s-cassandra.yaml" "k8s-elasticsearch.yaml")
        for MANIFEST in "${PLATFORM_MANIFESTS[@]}"; do
            if [ -f "$SCRIPT_DIR/$MANIFEST" ]; then kubectl apply -f "$SCRIPT_DIR/$MANIFEST"; fi
        done
        ;;
    shutdown)
        echo -e "${YELLOW}Shutting down GrocerSave...${NC}"
        export KUBECONFIG="$SCRIPT_DIR/.kubeconfig-localstack"

        if [ ! -f "$KUBECONFIG" ]; then
            echo -e "${RED}Local kubeconfig not found. Unable to connect to cluster to shutdown apps.${NC}"
            exit 1
        fi

        APP_MANIFESTS=("k8s-nginx.yaml" "k8s-frontend.yaml" "k8s-bff.yaml" "k8s-auth.yaml" "k8s-catalog.yaml" "k8s-price.yaml")
        for MANIFEST in "${APP_MANIFESTS[@]}"; do
            if [ -f "$SCRIPT_DIR/$MANIFEST" ]; then kubectl delete -f "$SCRIPT_DIR/$MANIFEST" --ignore-not-found; fi
        done

        PLATFORM_MANIFESTS=("k8s-redis.yaml" "k8s-postgres.yaml" "k8s-rabbitmq.yaml" "k8s-cassandra.yaml" "k8s-elasticsearch.yaml")
        for MANIFEST in "${PLATFORM_MANIFESTS[@]}"; do
            if [ -f "$SCRIPT_DIR/$MANIFEST" ]; then kubectl delete -f "$SCRIPT_DIR/$MANIFEST" --ignore-not-found; fi
        done

        if [ -f "$SCRIPT_DIR/k8s-namespace.yaml" ]; then kubectl delete -f "$SCRIPT_DIR/k8s-namespace.yaml" --ignore-not-found; fi
        ;;
    *)
        echo "Usage: ./deploy-grocersave.sh [all|shutdown|frontend|bff|auth|catalog|price|nginx|platform]"
        ;;
esac