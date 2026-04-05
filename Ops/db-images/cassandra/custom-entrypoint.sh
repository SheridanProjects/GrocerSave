#!/bin/bash
set -e

echo "ziko ziko - Starting Cassandra Initialization Wrapper"

# 1. Start Cassandra via the official entrypoint in the background
# (Removed the leading slash so it relies on the system PATH)
docker-entrypoint.sh cassandra -R -f &
CASSANDRA_PID=$!

# --- Health Check ---
echo "Waiting for Cassandra to start..."
while ! cqlsh -e "DESCRIBE KEYSPACES;" > /dev/null 2>&1; do
  echo -n "."
  sleep 5
done
echo "Cassandra is up and running."

# --- Initialization ---
echo "Running initialization script (init.cql)..."
cqlsh -f /init.cql || echo "Init script failed or already ran."
echo "Initialization script finished."

# --- Keep Container Running ---
wait $CASSANDRA_PID