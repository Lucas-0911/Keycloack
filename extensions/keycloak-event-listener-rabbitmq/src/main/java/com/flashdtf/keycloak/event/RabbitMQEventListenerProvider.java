package com.flashdtf.keycloak.event;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import org.keycloak.events.Event;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventType;
import org.keycloak.events.admin.AdminEvent;
import org.keycloak.events.admin.OperationType;
import org.keycloak.events.admin.ResourceType;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.TimeoutException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Keycloak Event Listener Provider that publishes events to RabbitMQ
 * for downstream system synchronization.
 *
 * <p>
 * Handles the following events:
 * </p>
 * <ul>
 * <li><strong>REGISTER</strong> - When a new user registers</li>
 * <li><strong>Admin USER UPDATE</strong> - When an admin blocks/disables a
 * user</li>
 * </ul>
 */
public class RabbitMQEventListenerProvider implements EventListenerProvider {

    private static final Logger LOGGER = Logger.getLogger(RabbitMQEventListenerProvider.class.getName());
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final KeycloakSession session;
    private final Connection rabbitConnection;
    private final String queueName;

    public RabbitMQEventListenerProvider(KeycloakSession session, Connection rabbitConnection, String queueName) {
        this.session = session;
        this.rabbitConnection = rabbitConnection;
        this.queueName = queueName;
    }

    @Override
    public void onEvent(Event event) {
        if (EventType.REGISTER.equals(event.getType())) {
            handleUserRegistration(event);
        }
    }

    @Override
    public void onEvent(AdminEvent adminEvent, boolean includeRepresentation) {
        // Listen for admin updates on USER resources (e.g., block/disable)
        if (ResourceType.USER.equals(adminEvent.getResourceType())
                && OperationType.UPDATE.equals(adminEvent.getOperationType())) {
            handleAdminUserUpdate(adminEvent);
        }
    }

    @Override
    public void close() {
        // Channel is created per-event, nothing to close here
    }

    /**
     * Handles user registration events by extracting user details
     * and publishing them to RabbitMQ.
     */
    private void handleUserRegistration(Event event) {
        try {
            String userId = event.getUserId();
            String realmId = event.getRealmId();

            RealmModel realm = session.realms().getRealm(realmId);
            UserModel user = session.users().getUserById(realm, userId);

            if (user == null) {
                LOGGER.warning("User not found for registration event. userId=" + userId);
                return;
            }

            ObjectNode message = buildUserMessage("USER_REGISTERED", realmId, user);
            message.put("createdTimestamp", user.getCreatedTimestamp());

            String jsonMessage = OBJECT_MAPPER.writeValueAsString(message);
            publishToRabbitMQ(jsonMessage);

            LOGGER.info("Published USER_REGISTERED event. userId=" + userId + ", email=" + user.getEmail());

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to publish registration event to RabbitMQ", e);
        }
    }

    /**
     * Handles admin user update events. Specifically detects when a user
     * is disabled (blocked) or re-enabled by an admin and publishes the
     * change to RabbitMQ.
     */
    private void handleAdminUserUpdate(AdminEvent adminEvent) {
        try {
            // Extract userId from the resource path (e.g., "users/uuid-here")
            String resourcePath = adminEvent.getResourcePath();
            if (resourcePath == null || !resourcePath.startsWith("users/")) {
                return;
            }
            String userId = resourcePath.substring("users/".length());

            // Check if the representation contains "enabled" field change
            String representation = adminEvent.getRepresentation();
            if (representation == null || representation.isBlank()) {
                return;
            }

            JsonNode repNode = OBJECT_MAPPER.readTree(representation);
            if (!repNode.has("enabled")) {
                // Not a block/unblock event, skip
                return;
            }

            boolean enabled = repNode.get("enabled").asBoolean();
            String realmId = adminEvent.getRealmId();
            RealmModel realm = session.realms().getRealm(realmId);
            UserModel user = session.users().getUserById(realm, userId);

            if (user == null) {
                LOGGER.warning("User not found for admin update event. userId=" + userId);
                return;
            }

            String eventType = enabled ? "USER_ENABLED" : "USER_BLOCKED";
            ObjectNode message = buildUserMessage(eventType, realmId, user);
            message.put("enabled", enabled);
            message.put("adminId", adminEvent.getAuthDetails().getUserId());

            String jsonMessage = OBJECT_MAPPER.writeValueAsString(message);
            publishToRabbitMQ(jsonMessage);

            LOGGER.info("Published " + eventType + " event. userId=" + userId + ", email=" + user.getEmail());

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to publish admin user update event to RabbitMQ", e);
        }
    }

    /**
     * Builds a standard user JSON message with common fields.
     */
    private ObjectNode buildUserMessage(String eventType, String realmId, UserModel user) {
        ObjectNode message = OBJECT_MAPPER.createObjectNode();
        message.put("eventType", eventType);
        message.put("timestamp", DateTimeFormatter.ISO_INSTANT.format(Instant.now().atOffset(ZoneOffset.UTC)));
        message.put("realmId", realmId);
        message.put("userId", user.getId());
        message.put("username", user.getUsername());
        message.put("email", user.getEmail());
        message.put("firstName", user.getFirstName());
        message.put("lastName", user.getLastName());
        message.put("emailVerified", user.isEmailVerified());
        return message;
    }

    /**
     * Publishes a JSON message to the configured RabbitMQ queue.
     * Creates a new channel for each message to ensure thread safety.
     */
    private void publishToRabbitMQ(String jsonMessage) throws IOException, TimeoutException {
        if (rabbitConnection == null || !rabbitConnection.isOpen()) {
            LOGGER.warning("RabbitMQ connection is not available. Skipping message publish.");
            return;
        }

        Channel channel = null;
        try {
            channel = rabbitConnection.createChannel();
            channel.queueDeclare(queueName, true, false, false, null);
            channel.basicPublish("", queueName, null, jsonMessage.getBytes(StandardCharsets.UTF_8));
        } finally {
            if (channel != null && channel.isOpen()) {
                try {
                    channel.close();
                } catch (Exception e) {
                    LOGGER.log(Level.FINE, "Error closing RabbitMQ channel", e);
                }
            }
        }
    }
}
