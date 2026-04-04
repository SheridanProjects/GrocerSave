# Use the official Cassandra image as a base
FROM cassandra:4.0

# Copy files directly to the root
COPY init.cql /init.cql
COPY price_history.csv /price_history.csv
COPY custom-entrypoint.sh /custom-entrypoint.sh

# Make the script executable
RUN chmod +x /custom-entrypoint.sh

# Set the custom script as the strict entrypoint
ENTRYPOINT ["/custom-entrypoint.sh"]