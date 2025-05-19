# Use multi-stage builds

# --- Backend Stage: Build Spring Boot Application ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder
WORKDIR /app/backend  # Create a separate directory for the backend
COPY ./backend/pom.xml ./  
COPY ./backend/src ./src
RUN mvn clean package -DskipTests

# --- Frontend Stage: Build Angular Application ---
FROM node:18-alpine AS frontend_builder
WORKDIR /app/frontend # Create a separate directory for the frontend
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend .
RUN npm install -g @angular/cli
RUN ng build --configuration production

# --- Final Stage:  Combine Backend and Frontend ---
FROM openjdk:21-jdk-slim
WORKDIR /app

# Copy the Spring Boot JAR from the backend build stage
COPY --from=backend_builder /app/backend/target/*.jar ./backend.jar

# Copy the Angular build output from the frontend build stage
COPY --from=frontend_builder /app/frontend/dist /app/dist

# Expose the necessary ports
EXPOSE 8080
EXPOSE 80

# --- Entrypoint Script ---
# Create a script to start either the backend or the frontend
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
