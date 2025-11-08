# Multi-Stage Build for Java/Maven Application

# --- STAGE 1: BUILD ---
FROM maven:3.9.6-eclipse-temurin-21 AS build

# Set the working directory
WORKDIR /app

# Copy the dependency definition first (pom.xml)
# This leverages Docker layer caching if dependencies haven't changed
COPY pom.xml .

# Download dependencies (effectively 'mvn dependency:go-offline')
RUN mvn dependency:resolve

# Copy the rest of the application source code
COPY src ./src

# Build the final JAR/WAR
RUN mvn package -DskipTests

# --- STAGE 2: RUNTIME ---
# Use a lightweight JRE (Java Runtime Environment) image
Q-jre-focal AS run

# Arguments and Environment
ARG JAR_FILE=target/*.jar
ENV PORT=8080

# Expose the application port
EXPOSE $PORT

# Copy the built artifact from the build stage
COPY --from=build /app/$JAR_FILE app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "/app.jar"]