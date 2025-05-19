# --- Backend Stage: Build Spring Boot Application ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder
WORKDIR /app/backend
COPY ./backend/pom.xml .
COPY ./backend/src ./src

# Build the backend JAR
RUN mvn clean package -DskipTests && \
    ls -alh target  # Debug: Show the built artifacts

# --- Frontend Stage: Build Angular Application ---
FROM node:18-alpine AS frontend_builder
WORKDIR /app/frontend
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend .
RUN npm install -g @angular/cli
RUN ng build --configuration production

# --- Final Stage: Combine Backend and Frontend ---
FROM openjdk:21-jdk-slim
WORKDIR /app

# Copy the built Spring Boot JAR from backend_builder
# Replace 'your-app-name.jar' with actual JAR name (from backend build output)
COPY --from=backend_builder /app/backend/target/your-app-name.jar ./backend.jar

# Copy Angular build output
COPY --from=frontend_builder /app/frontend/dist /app/dist

# Copy entrypoint script
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh

# Expose backend and frontend ports
EXPOSE 8080
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

