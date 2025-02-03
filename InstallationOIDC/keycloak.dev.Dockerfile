FROM quay.io/keycloak/keycloak:latest

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Create directory for realm imports
RUN mkdir -p /opt/keycloak/data/import

# Expose the web port
EXPOSE 8080

# Set the entry point
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]