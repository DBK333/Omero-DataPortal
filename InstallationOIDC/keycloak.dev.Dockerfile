# keycloak-26.1.Dockerfile
FROM quay.io/keycloak/keycloak:26.1

# (Optional) Add any custom files or configurations here.
# For example, if you need to copy scripts or configuration files:
# COPY ./my-config /opt/keycloak/my-config

# Use the built-in startup script with start-dev and our desired flags.
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev", "--spi-login-protocol-openid-connect-default-client-ssl-required=none", "--import-realm"]
