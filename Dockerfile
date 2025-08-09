# --- Этап 1: Сборка проекта с помощью Maven ---
# Используем образ с Maven и JDK 17. Даем ему имя "builder" для удобства.
FROM maven:3.8.6-eclipse-temurin-17-focal AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем сначала pom.xml, чтобы воспользоваться кэшированием Docker.
# Слой с зависимостями будет пересобираться только при изменении pom.xml.
COPY pom.xml .
RUN mvn dependency:go-offline

# Теперь копируем остальной исходный код
COPY src ./src

# Собираем проект, пропуская тесты (предполагаем, что они запускаются на отдельном шаге CI).
# Плагин создаст "слоеный" JAR.
RUN mvn package -DskipTests

# --- Этап 2: Распаковка слоев ---
# Этот промежуточный этап нужен, чтобы извлечь слои из JAR-файла,
# созданного Spring Boot.
FROM eclipse-temurin:17-jre-alpine AS unpacker
WORKDIR /app
COPY --from=builder /app/target/*.jar ./application.jar
# Распаковываем JAR, чтобы получить директории слоев (BOOT-INF/layers)
RUN java -Djarmode=layertools -jar application.jar extract

# --- Этап 3: Создание финального образа ---
# Используем минимальный базовый образ только с Java Runtime
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Создаем группу и пользователя с ограниченными правами
RUN addgroup -S spring && adduser -S spring -G spring

# Устанавливаем этого пользователя для всех последующих команд
USER spring:spring

# Копируем слои из этапа "unpacker" в правильном порядке:
# сначала зависимости, потом все остальное.
COPY --from=unpacker /app/dependencies/ ./
COPY --from=unpacker /app/spring-boot-loader/ ./
COPY --from=unpacker /app/snapshot-dependencies/ ./
COPY --from=unpacker /app/application/ ./

# Указываем, как запускать наше приложение
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]