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

# Copy project source
COPY src ./src
COPY frontend ./frontend

# ============================
# 🔥 FRONTEND BUILD (FIXED)
# ============================

# Install frontend dependencies
RUN cd frontend && npm install

# Fix permission issue (VERY IMPORTANT)
RUN chmod -R +x frontend/node_modules/.bin

# Build React app
RUN cd frontend && npm run build

# Copy React build into Spring Boot static folder
RUN mkdir -p src/main/resources/static && \
    cp -r frontend/dist/* src/main/resources/static/

# ============================
# 🔥 BACKEND BUILD
# ============================

RUN mvn clean package -DskipTests

# ============================================================
# Stage 2: Runtime (Lightweight image)
# ============================================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy JAR from build stage
COPY --from=build /build/target/*.jar app.jar

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.jar"]