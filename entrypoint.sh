#!/bin/bash

# Check the environment variable to determine which application to start
if [ "$APP_TYPE" = "backend" ]; then
  echo "Starting Backend (Spring Boot)..."
  java -jar /app/backend.jar
elif [ "$APP_TYPE" = "frontend" ]; then
  echo "Starting Frontend (Nginx)..."
  nginx -g "daemon off;"
else
  echo "Error: APP_TYPE environment variable must be set to 'backend' or 'frontend'."
  exit 1
fi
