package com.flashdtf.keycloak.event;

import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import org.keycloak.Config;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventListenerProviderFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Factory for creating {@link RabbitMQEventListenerProvider} instances.
 *
 * <p>Manages the RabbitMQ connection lifecycle and reads configuration
 * from environment variables:</p>
 * <ul>
 *     <li>{@code RABBITMQ_HOST} - RabbitMQ server host (default: localhost)</li>
 *     <li>{@code RABBITMQ_PORT} - RabbitMQ server port (default: 5672)</li>
 *     <li>{@code RABBITMQ_USERNAME} - RabbitMQ username (default: guest)</li>
 *     <li>{@code RABBITMQ_PASSWORD} - RabbitMQ password (default: guest)</li>
 *     <li>{@code RABBITMQ_QUEUE_NAME} - Target queue name (default: keycloak.user.registered)</li>
 * </ul>
 */
public class RabbitMQEventListenerProviderFactory implements EventListenerProviderFactory {

    private static final Logger LOGGER = Logger.getLogger(RabbitMQEventListenerProviderFactory.class.getName());
    private static final String PROVIDER_ID = "rabbitmq-event-listener";

    private Connection rabbitConnection;
    private String queueName;

    // RabbitMQ connection parameters
    private String host;
    private int port;
    private String username;
    private String password;

    @Override
    public EventListenerProvider create(KeycloakSession keycloakSession) {
        // Ensure connection is alive
        ensureConnection();
        return new RabbitMQEventListenerProvider(keycloakSession, rabbitConnection, queueName);
    }

    @Override
    public void init(Config.Scope scope) {
        // Read configuration from environment variables
        this.host = getEnvOrDefault("RABBITMQ_HOST", "localhost");
        this.port = Integer.parseInt(getEnvOrDefault("RABBITMQ_PORT", "5672"));
        this.username = getEnvOrDefault("RABBITMQ_USERNAME", "guest");
        this.password = getEnvOrDefault("RABBITMQ_PASSWORD", "guest");
        this.queueName = getEnvOrDefault("RABBITMQ_QUEUE_NAME", "keycloak.user.registered");

        LOGGER.info("RabbitMQ Event Listener initialized. Host=" + host + ", Port=" + port + ", Queue=" + queueName);
    }

    @Override
    public void postInit(KeycloakSessionFactory keycloakSessionFactory) {
        // Establish RabbitMQ connection after full Keycloak initialization
        ensureConnection();
    }

    @Override
    public void close() {
        if (rabbitConnection != null && rabbitConnection.isOpen()) {
            try {
                rabbitConnection.close();
                LOGGER.info("RabbitMQ connection closed.");
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error closing RabbitMQ connection", e);
            }
        }
    }

    @Override
    public String getId() {
        return PROVIDER_ID;
    }

    /**
     * Ensures a valid RabbitMQ connection exists.
     * If the connection is null or closed, attempts to create a new one.
     */
    private synchronized void ensureConnection() {
        if (rabbitConnection != null && rabbitConnection.isOpen()) {
            return;
        }

        try {
            ConnectionFactory factory = new ConnectionFactory();
            factory.setHost(host);
            factory.setPort(port);
            factory.setUsername(username);
            factory.setPassword(password);

            // Enable automatic recovery
            factory.setAutomaticRecoveryEnabled(true);
            factory.setNetworkRecoveryInterval(5000); // 5 seconds

            // Connection timeout
            factory.setConnectionTimeout(10000); // 10 seconds

            rabbitConnection = factory.newConnection("keycloak-event-listener");
            LOGGER.info("RabbitMQ connection established successfully. Host=" + host + ":" + port);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to establish RabbitMQ connection. Events will NOT be published. Host=" + host + ":" + port, e);
            rabbitConnection = null;
        }
    }

    /**
     * Gets an environment variable value, or returns the default if not set.
     */
    private static String getEnvOrDefault(String envVar, String defaultValue) {
        String value = System.getenv(envVar);
        return (value != null && !value.isBlank()) ? value : defaultValue;
    }
}
