# Multi-stage Docker build
FROM eclipse-temurin:21-jdk-alpine AS builder

# Install git for potential dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy gradle wrapper and build files
COPY gradlew .
COPY gradlew.bat .
COPY gradle/ gradle/
COPY settings.gradle.kts .
COPY gradle.properties .

# Copy all source code and build files
COPY game-server/ game-server/
COPY game-client/ game-client/

# Make gradlew executable
RUN chmod +x gradlew

# Build the project (this will download dependencies and build both server and client)
RUN ./gradlew build -x test --no-daemon

# Production stage
FROM eclipse-temurin:21-jre-alpine

# Install necessary packages
RUN apk add --no-cache \
    bash \
    curl \
    unzip

# Create app user
RUN adduser -D -s /bin/bash app

# Set working directory
WORKDIR /app

# Copy built artifacts from builder stage
COPY --from=builder /app/game-server/build/libs/ /app/game-server/libs/
COPY --from=builder /app/game-client/build/libs/ /app/game-client/libs/

# Copy necessary runtime files
COPY --from=builder /app/game-server/data/ /app/game-server/data/
COPY --from=builder /app/game-server/settings.toml /app/game-server/
COPY --from=builder /app/game-server/plugins/ /app/game-server/plugins/
COPY --from=builder /app/game-server/inter/ /app/game-server/inter/

# Create cache directory
RUN mkdir -p /app/game-server/data/cache

# Change ownership to app user
RUN chown -R app:app /app

# Switch to app user
USER app

# Expose default ports (commonly used for RSPS)
EXPOSE 43594 8080

# Default command to run the server
CMD ["java", "-XX:-OmitStackTraceInFastThrow", "--enable-preview", "-XX:+UseZGC", "-Xmx4g", "-Xms2g", "-XX:MaxGCPauseMillis=100", "-jar", "/app/game-server/libs/game-server-all.jar"]
