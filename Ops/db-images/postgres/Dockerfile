# Use the official PostgreSQL image as a base
FROM postgres:14-alpine

# The PostgreSQL image will automatically run any .sql, .sql.gz, or .sh scripts
# found in the /docker-entrypoint-initdb.d directory upon first startup.
# They are executed in alphabetical order.

# Copy all our initialization scripts into the container.
COPY *.sql /docker-entrypoint-initdb.d/
