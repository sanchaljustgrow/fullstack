# --- Stage 1: Build Angular App ---
FROM node:18-alpine AS frontend_builder

WORKDIR /app

# Install dependencies
COPY frontend/package*.json ./
RUN npm install

# Copy the rest of the Angular source code and build the production app
COPY frontend/ ./
RUN npm install -g @angular/cli && \
    ng build --configuration production

# --- Stage 2: Build Spring Boot App ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder

WORKDIR /app

# Copy pom.xml and install dependencies
COPY backend/pom.xml ./
RUN mvn dependency:go-offline

# Copy the rest of the backend source code
COPY backend/ ./src

# Build the Spring Boot JAR
RUN mvn clean package -DskipTests

# --- Stage 3: Combine Frontend (Nginx) and Backend (Spring Boot) ---
FROM openjdk:21-jdk-slim

# Install Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the Spring Boot JAR file from the backend build stage
COPY --from=backend_builder /app/target/*.jar /app/app.jar

# Remove default Nginx configuration and add custom one
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the Angular build files to the Nginx folder
COPY --from=frontend_builder /app/dist/angular13-fundamentals-workshop /usr/share/nginx/html

# Expose the necessary ports
EXPOSE 8080  # Spring Boot
EXPOSE 8081  # Nginx

# Use entrypoint script to start both services
COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
