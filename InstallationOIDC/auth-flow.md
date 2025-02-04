# Authentication Flow Diagram

```mermaid
sequenceDiagram
   participant User
   participant Proxy
   participant Web as OMERO.web
   participant Server as OMERO.server
   participant Keycloak
   participant Auth0
   participant LDAP

   rect rgb(240, 248, 255)
       Note over User,LDAP: First Login Flow
       User->>Proxy: Access OMERO
       Proxy->>Web: Forward
       Web->>Keycloak: Login redirect
       Keycloak->>Auth0: Auth redirect
       Auth0->>User: Login form
       User->>Auth0: Credentials
       Auth0->>Keycloak: User + Token
       Keycloak->>LDAP: Sync user
       LDAP-->>Keycloak: Confirmed
       Keycloak-->>Web: OIDC token
       Web->>Server: Create user
       Server->>LDAP: Validate
       LDAP-->>Server: Confirmed
       Server-->>Web: Success
       Web-->>User: Dashboard
   end

   rect rgb(248, 250, 252)
       Note over User,LDAP: Return Login Flow
       User->>Proxy: Access
       Proxy->>Web: Forward
       Web->>Keycloak: Auth check
       Keycloak->>LDAP: Validate
       LDAP-->>Keycloak: Valid
       Keycloak-->>Web: Token
       Web->>Server: Auth
       Server->>LDAP: Verify
       LDAP-->>Server: Valid
       Server-->>Web: Success
       Web-->>User: Access
   end