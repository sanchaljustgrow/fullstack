# --- Stage 1: Build Angular App ---
FROM node:18-alpine AS builder

WORKDIR /app

# Copy frontend package files
COPY frontend/package*.json ./frontend/
RUN npm install --prefix ./frontend

# Copy the rest of the frontend files and build the Angular app
COPY frontend/ ./frontend/
RUN npm install -g @angular/cli && \
    ng build --configuration production --prefix ./frontend

# --- Stage 2: Build Spring Boot App ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder

WORKDIR /app

# Copy backend Maven files
COPY backend/pom.xml ./backend/
COPY backend/src ./backend/src

# Build the Spring Boot JAR
RUN mvn clean package -DskipTests --file backend/pom.xml

# --- Stage 3: Serve Both Frontend and Backend ---
FROM openjdk:21-jdk-slim AS final

WORKDIR /app

# Copy the built Spring Boot JAR
COPY --from=backend_builder /app/backend/target/*.jar ./backend.jar

# Copy the built Angular app to Nginx static folder
COPY --from=builder /app/frontend/dist /usr/share/nginx/html

# Expose ports for both frontend (8081) and backend (8080)
EXPOSE 8080  # Backend port
EXPOSE 8081  # Frontend port (Nginx)

# Install Nginx to serve the frontend and run both backend and frontend
RUN apt-get update && apt-get install -y nginx

# Copy entrypoint script to start both services
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
