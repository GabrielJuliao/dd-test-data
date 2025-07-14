# Stage 1: Build the application using Maven and Java
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy Maven project files
COPY pom.xml .
COPY src ./src

# Build the application (produces a JAR file)
RUN mvn clean package

# Stage 2: Create a lightweight runtime image with Alpine
FROM alpine:3.10

# Install OpenJDK 8 on Alpine
RUN apk update && \
    apk add --no-cache openjdk8-jre && \
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port (optional, adjust based on your app)
EXPOSE 8080

# Set entrypoint to run the Java application
ENTRYPOINT ["java", "-jar", "app.jar"]