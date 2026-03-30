#!/bin/bash

# -----------------------------------------------------------------------------
# Script to deploy a large PostgreSQL seed file to a Kubernetes pod.
#
# This script accepts Kubernetes and database configuration as command-line
# parameters.
#
# Pre-requisites:
# 1. The 'postgres_seed_large.sql' file must be in the same directory.
# 2. You must be authenticated with a Kubernetes cluster.
# -----------------------------------------------------------------------------

# --- Default Configuration ---
K8S_NAMESPACE="default"
POSTGRES_POD_NAME=""
PG_USER="postgres"
PG_DB="postgres"

# --- Help Message ---
usage() {
  echo "Usage: $0 -p <postgres_pod_name> [-n <k8s_namespace>] [-u <pg_user>] [-d <pg_db>]"
  echo ""
  echo "Deploys a large seed file to a PostgreSQL pod in Kubernetes."
  echo ""
  echo "Parameters:"
  echo "  -p, --postgres-pod   Name of the PostgreSQL pod (required)."
  echo "  -n, --namespace      Kubernetes namespace (default: 'default')."
  echo "  -u, --pg-user        PostgreSQL user (default: 'postgres')."
  echo "  -d, --pg-db          PostgreSQL database name (default: 'postgres')."
  echo "  -h, --help           Display this help message."
  echo ""
  echo "Example:"
  echo "  ./deploy_large_seed.sh -p my-postgres-pod-xyz -n my-app-ns -u grocer_admin -d grocersave_db"
}

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -p|--postgres-pod) POSTGRES_POD_NAME="$2"; shift 2 ;;
    -n|--namespace) K8S_NAMESPACE="$2"; shift 2 ;;
    -u|--pg-user) PG_USER="$2"; shift 2 ;;
    -d|--pg-db) PG_DB="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
  esac
done

# --- Validation ---
if [[ -z "$POSTGRES_POD_NAME" ]]; then
  echo "🛑 ERROR: Missing required parameter: -p <postgres_pod_name>"
  usage
  exit 1
fi

# --- Deployment ---
echo "Deploying PostgreSQL seed data with the following configuration:"
echo "  Namespace:          $K8S_NAMESPACE"
echo "  PostgreSQL Pod:     $POSTGRES_POD_NAME"
echo "  PostgreSQL User:    $PG_USER"
echo "  PostgreSQL DB:      $PG_DB"
echo "----------------------------------------------------------------"

echo "1. Loading PostgreSQL data from 'postgres_seed_large.sql'..."
cat postgres_seed_large.sql | kubectl exec -n "$K8S_NAMESPACE" -i "$POSTGRES_POD_NAME" -- psql -U "$PG_USER" -d "$PG_DB"
if [ $? -eq 0 ]; then
    echo "✅ PostgreSQL data loaded successfully."
else
    echo "❌ ERROR: Failed to load PostgreSQL data."
    exit 1
fi

echo ""
echo "----------------------------------------------------------------"
echo "Deployment script finished."
echo "----------------------------------------------------------------"
echo ""
echo "To VERIFY the data after loading:"
echo "----------------------------------------------------------------"
echo "✅ Verify Postgres Product Count (should be ~300):"
echo "   kubectl exec -n \"$K8S_NAMESPACE\" -i \"$POSTGRES_POD_NAME\" -- psql -U \"$PG_USER\" -d \"$PG_DB\" -c \"SELECT COUNT(*) FROM products;\""
echo ""
echo "----------------------------------------------------------------"
