#!/bin/sh
java -jar /app/backend.jar &  # Start Spring Boot in the background
nginx -g "daemon off;"        # Start Nginx in the foreground
