#!/bin/sh
set -e

echo "Starting Quenta application..."

echo "Running database migrations..."
./bin/quenta eval "Quenta.Release.migrate()"
echo "Migrations completed."

# Start the Phoenix application
echo "Starting Phoenix server..."
exec ./bin/quenta start
