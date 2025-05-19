# --- Backend Stage: Build Spring Boot Application ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder
WORKDIR /app/backend

# Copy Maven project files
COPY ./backend/pom.xml .
COPY ./backend/src ./src

# Build the backend JAR and rename it to app.jar
RUN mvn clean package -DskipTests && \
    cp target/*.jar app.jar

# --- Frontend Stage: Build Angular Application ---
FROM node:18-alpine AS frontend_builder
WORKDIR /app/frontend

# Install dependencies and build Angular app
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend .
RUN npm install -g @angular/cli
RUN ng build --configuration production

# --- Final Stage: Combine Backend and Frontend ---
# --- Final Stage: Combine Backend and Frontend ---
FROM openjdk:21-jdk-slim
WORKDIR /app

# Copy the renamed backend JAR
COPY --from=backend_builder /app/backend/app.jar ./backend.jar

# ✅ Copy the Angular production build to Spring Boot's static resource folder
COPY --from=frontend_builder /app/frontend/dist /app/resources/static

# Copy entrypoint script (make sure it's in the project root)
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh

# Expose backend and frontend ports
EXPOSE 8080
EXPOSE 80

# Start the application
ENTRYPOINT ["/entrypoint.sh"]
