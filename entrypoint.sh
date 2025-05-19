#!/bin/bash

if [ -f "/app/backend.jar" ]; then
  echo "Starting Backend (Spring Boot)..."
  java -jar /app/backend.jar
elif [ -d "/app/dist" ]; then
  echo "Starting Frontend (Nginx)..."
  nginx -g "daemon off;"
else
  echo "Error: No application to run.  Make sure backend.jar or /app/dist exists."
  exit 1
fi
