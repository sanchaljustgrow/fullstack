# Stage 1: Build backend
FROM maven:3.9.6-eclipse-temurin-21 AS backend-builder
WORKDIR /app
COPY backend/pom.xml .
COPY backend/src ./src
RUN mvn clean package -DskipTests

# Stage 2: Build frontend (if needed)
FROM node:16 AS frontend-builder
WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/src ./src
RUN npm run build

# Stage 3: Final image (e.g., Java server)
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=backend-builder /app/target/app.jar ./app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
