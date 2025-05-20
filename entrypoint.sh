#!/bin/sh
# Start the Spring Boot application in the background
echo "Starting Spring Boot backend..."
java -jar /app/backend.jar &

# Start Nginx in the foreground
echo "Starting Nginx frontend..."
nginx -g "daemon off;"
