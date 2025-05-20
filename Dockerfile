# --- Stage 1: Build Angular App ---
FROM node:18-alpine AS frontend_builder

WORKDIR /app

# Copy package.json and package-lock.json for better caching
COPY ./frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy the Angular application source code
COPY ./frontend ./

# Build the Angular application for production
RUN npm run build --configuration production

# --- Stage 2: Build Spring Boot Application ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder

WORKDIR /app

# Copy only the pom.xml first for dependency resolution and caching
COPY ./backend/pom.xml ./

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline

# Copy the Spring Boot application source code
COPY ./backend/src ./src

# Build the Spring Boot application (skip tests for Docker builds)
RUN mvn clean package -DskipTests

# --- Final Stage: Combine Frontend and Backend ---
FROM openjdk:21-jdk-slim

# Install Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the backend JAR into the container
COPY --from=backend_builder /app/target/*.jar ./backend.jar

# Remove the default Nginx configuration
RUN rm -rf /etc/nginx/conf.d/*

# Copy the custom Nginx configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy the Angular build output to Nginx's web serving folder
COPY --from=frontend_builder /app/dist /usr/share/nginx/html

# Expose the necessary ports
EXPOSE 8081 # Frontend (Nginx)
EXPOSE 8080  # Backend (Spring Boot)

# Use a non-root user for security
USER nonroot:nonroot

# Set the entrypoint to start Nginx and Spring Boot
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
