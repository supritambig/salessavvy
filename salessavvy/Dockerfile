# ============================================================
# Stage 1: Build React frontend + Spring Boot backend
# ============================================================
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Install Node.js 20
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Cache Maven dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -q || true

# Copy source
COPY src ./src
COPY frontend ./frontend

# 🔥 Build frontend manually
RUN cd frontend && npm install && npm run build

# 🔥 Copy React build into Spring Boot
RUN mkdir -p src/main/resources/static && \
    cp -r frontend/dist/* src/main/resources/static/

# Build Spring Boot
RUN mvn clean package -DskipTests

# ============================================================
# Stage 2: Runtime
# ============================================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=build /build/target/*.jar app.jar

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.jar"]