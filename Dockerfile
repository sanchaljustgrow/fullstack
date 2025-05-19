# Use multi-stage builds to keep the final image small

# --- Backend Stage (Maven/Spring Boot) ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder
WORKDIR /app
COPY ./backend .  # Copy the backend code.  <--- Make sure this path is correct!
RUN mvn clean package -DskipTests

# --- Frontend Stage (Node/Angular) ---
FROM node:18-alpine AS frontend_builder
WORKDIR /app
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend . # Copy the frontend code
RUN npm run build --configuration production

# --- Final Stage (Combining Backend and Frontend) ---
FROM openjdk:21-jdk-slim
WORKDIR /app

# Copy the backend JAR from the backend_builder stage
COPY --from=backend_builder /app/target/*.jar ./backend.jar

# Copy the frontend build output from the frontend_builder stage
COPY --from=frontend_builder /app/dist/frontend /app/frontend

# Expose ports for both applications
EXPOSE 8080
EXPOSE 80

# --- Entrypoint Script ---
# Create a script to start either the backend or the frontend
# This script will be used as the ENTRYPOINT
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
