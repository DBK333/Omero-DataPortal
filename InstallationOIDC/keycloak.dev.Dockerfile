# keycloak-26.1.Dockerfile
FROM quay.io/keycloak/keycloak:26.1

# (Optional) Copy custom scripts or configurations here
# COPY ./custom-scripts /opt/keycloak/custom-scripts

# Use the built-in startup script with desired flags.
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev", "--spi-login-protocol-openid-connect-default-client-ssl-required=none", "--import-realm"]
