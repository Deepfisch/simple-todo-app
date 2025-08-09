# --- Этап 1: Сборка проекта с помощью Maven ---
FROM maven:3.8.6-eclipse-temurin-17-focal AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# --- Этап 2: Распаковка слоев ---
FROM eclipse-temurin:17-jre-alpine AS unpacker
WORKDIR /app
COPY --from=builder /app/target/*.jar ./application.jar
RUN java -Djarmode=layertools -jar application.jar extract

# --- Этап 3: Создание финального образа ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
COPY --from=unpacker /app/dependencies/ ./
COPY --from=unpacker /app/spring-boot-loader/ ./
COPY --from=unpacker /app/snapshot-dependencies/ ./
COPY --from=unpacker /app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]