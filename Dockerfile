# =============================================
# Dockerfile for Keycloak with custom extension
# Builds the RabbitMQ Event Listener JAR and
# includes it in the Keycloak image
# =============================================

# Stage 1: Build the RabbitMQ extension JAR
FROM maven:3.9-eclipse-temurin-21 AS extension-builder

WORKDIR /build
COPY extensions/keycloak-event-listener-rabbitmq/pom.xml ./pom.xml
RUN mvn dependency:go-offline -q
COPY extensions/keycloak-event-listener-rabbitmq/src ./src
RUN mvn clean package -q -DskipTests

# Stage 2: Build the Captcha extension JAR
FROM maven:3.9-eclipse-temurin-21 AS captcha-builder

WORKDIR /build
COPY extensions/keycloak-captcha-login/pom.xml ./pom.xml
RUN mvn dependency:go-offline -q
COPY extensions/keycloak-captcha-login/src ./src
RUN mvn clean package -q -DskipTests

# Stage 3: Keycloak with extension
FROM quay.io/keycloak/keycloak:26.2

# Copy the built extension JARs into the providers directory
COPY --from=extension-builder /build/target/keycloak-event-listener-rabbitmq-1.0.0.jar /opt/keycloak/providers/
COPY --from=captcha-builder /build/target/keycloak-captcha-login-1.0.0.jar /opt/keycloak/providers/

# Build Keycloak to pick up the new provider
RUN /opt/keycloak/bin/kc.sh build
