FROM quay.io/keycloak/keycloak:26.1

# Optionally install any custom providers or do other config steps

# If you want to pre-load scripts into a specific folder:
# COPY realm-config/scripts /opt/keycloak/scripts

# By default:
# * We'll run Keycloak with dev profile
# * We'll rely on the environment variable KC_FEATURES=scripts to enable script-based auth.
