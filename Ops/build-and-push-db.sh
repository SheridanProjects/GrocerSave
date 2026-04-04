#!/bin/bash
set -e

# This script builds and pushes custom Docker images for PostgreSQL and Cassandra.
# It includes a '--capture' flag to snapshot data from live databases.

# --- ROBUST PATHS ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# --- CONFIGURATION ---
DB_TYPE=$1
VERSION=$2
DOCKER_HUB_USER=$3
CAPTURE_FLAG=$4
NAMESPACE="grocersave-dev"

# --- VALIDATION ---
if [ -z "$DB_TYPE" ] || [ -z "$VERSION" ] || [ -z "$DOCKER_HUB_USER" ]; then
  echo "❌ ERROR: Missing arguments."
  echo "Usage: $0 <db_type> <version> <docker_hub_username> [--capture]"
  echo "Example: $0 postgres 1.3 mydockeruser --capture"
  exit 1
fi

if [ "$DB_TYPE" != "postgres" ] && [ "$DB_TYPE" != "cassandra" ]; then
    echo "❌ ERROR: Invalid db_type. Must be 'postgres' or 'cassandra'."
    exit 1
fi

# --- SCRIPT LOGIC ---
IMAGE_NAME="${DOCKER_HUB_USER}/${DB_TYPE}-grocersave"
CONTEXT_PATH="${SCRIPT_DIR}/db-images/${DB_TYPE}"

# --- DATA CAPTURE / PRE-BUILD PREPARATION ---
if [ "$DB_TYPE" == "cassandra" ]; then
    # Ensure the CSV file exists for the Docker build, even if not capturing.
    # The COPY command in the Dockerfile will fail otherwise.
    touch "${CONTEXT_PATH}/price_history.csv"
fi

if [ "$CAPTURE_FLAG" == "--capture" ]; then
    echo "--------------------------------------------------"
    echo "📸 Capturing live data from ${DB_TYPE}..."
    echo "--------------------------------------------------"

    POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app="$DB_TYPE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -z "$POD_NAME" ]; then
        echo "❌ ERROR: Could not find a running '$DB_TYPE' pod in namespace '$NAMESPACE'."
        echo "   Please ensure the database is running before using --capture."
        exit 1
    fi
    echo "  Found live pod: $POD_NAME"

    if [ "$DB_TYPE" == "postgres" ]; then
        DATA_FILE_PATH="${CONTEXT_PATH}/02-data.sql"
        echo "  Dumping 'users' and 'products' tables from '$POD_NAME' into '$DATA_FILE_PATH'..."
        # Note: -it is okay for pg_dump as it doesn't typically cause the same TTY issues.
        kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- \
          pg_dump -U postgres -d postgres --data-only --inserts --table=public.users --table=public.products > "$DATA_FILE_PATH"

    elif [ "$DB_TYPE" == "cassandra" ]; then
        DATA_FILE_PATH="${CONTEXT_PATH}/price_history.csv"
        echo "  Exporting 'price_service.price_history' table from '$POD_NAME' to a CSV..."

        # Remove -it for non-interactive commands to ensure clean output for redirection.
        kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- \
          cqlsh -e "COPY price_service.price_history TO STDOUT WITH HEADER = true;" > "$DATA_FILE_PATH"
    fi

    echo "✅ Data capture complete."
fi


echo "--------------------------------------------------"
echo "🚀 Building and pushing image for: ${DB_TYPE}"
echo "   Version: ${VERSION}"
echo "   Image: ${IMAGE_NAME}"
echo "   Build Context: ${CONTEXT_PATH}"
echo "--------------------------------------------------"

# 1. Login to Docker Hub
echo "🔐 Authenticating with Docker Hub..."
docker login

# 2. Build the Docker image
echo "🛠️ Building image: ${IMAGE_NAME}:${VERSION}"
docker build --no-cache --pull -t "${IMAGE_NAME}:${VERSION}" "${CONTEXT_PATH}"

# 3. Tag the image as 'latest'
echo "🏷️ Tagging ${IMAGE_NAME}:${VERSION} as ${IMAGE_NAME}:latest"
docker tag "${IMAGE_NAME}:${VERSION}" "${IMAGE_NAME}:latest"

# 4. Push the versioned tag
echo " Pushing version tag: ${IMAGE_NAME}:${VERSION}"
docker push "${IMAGE_NAME}:${VERSION}"

# 5. Push the 'latest' tag
echo " Pushing latest tag: ${IMAGE_NAME}:latest"
docker push "${IMAGE_NAME}:latest"

echo "✅ Done. Image ${IMAGE_NAME} (version ${VERSION} and latest) pushed successfully."
