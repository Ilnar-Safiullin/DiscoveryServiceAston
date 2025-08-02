# Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Копируем JAR (учёт SNAPSHOT-версии)
COPY --from=builder /app/target/discovery-service-*.jar app.jar

# Настройки подключения к Config Server
ENV SPRING_PROFILES_ACTIVE=docker \
    SPRING_CONFIG_IMPORT=configserver:http://config-server:8888

EXPOSE 8761
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8761/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]