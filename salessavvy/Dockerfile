# ============================================================
# Stage 1: Build React frontend + Spring Boot backend in one go
# ============================================================
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Install Node.js 20
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Cache Maven dependencies first
COPY pom.xml .
RUN mvn dependency:go-offline -q || true

# Copy source (backend + frontend)
COPY src ./src
COPY frontend ./frontend

# Build everything: Maven will invoke frontend-maven-plugin to build React,
# then copy dist/ into static/, then package the JAR
RUN mvn clean package -DskipTests

# ============================================================
# Stage 2: Minimal runtime image
# ============================================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=build /build/target/*.jar app.jar

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.jar"]
