# --- Stage 1: Build Angular App ---
FROM node:18-alpine AS frontend_builder

WORKDIR /app

COPY ./frontend/package*.json ./
RUN npm install

COPY ./frontend ./
RUN npm run build --configuration production

# --- Stage 2: Build Spring Boot Application ---
FROM maven:3.9.6-eclipse-temurin-21 AS backend_builder

WORKDIR /app

COPY ./backend/pom.xml .
COPY ./backend/src ./src

RUN mvn clean package -DskipTests

# --- Final Stage: Combine Frontend and Backend ---
FROM openjdk:21-jdk-slim

# Install Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the Spring Boot JAR
COPY --from=backend_builder /app/target/*.jar ./backend.jar

# Remove default Nginx config and add custom one
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# ⚠️ Replace <your-angular-app> with actual output folder name (e.g. my-app)
COPY --from=frontend_builder /app/dist/angular13-fundamentals-workshop /usr/share/nginx/html 

# Expose backend and frontend ports
EXPOSE 8080   # Spring Boot
EXPOSE 8081   # Nginx

# Entrypoint script to run both services
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
