# Port Information for Services and Nodes

## Server Access

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 22           | SSH (Secure Shell)              |
| TCP      | 443          | HTTPS (Secure Web Access)       |

---

## Master Node Ports (Control Plane)

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 6443         | Kubernetes API server           |
| TCP      | 2379-2380    | etcd server client API          |
| TCP      | 10250        | Kubelet API                     |
| TCP      | 10251        | kube-scheduler                  |
| TCP      | 10252        | kube-controller-manager         |
| UDP      | 8472         | Flannel VXLAN overlay network   |

---

## Worker Node Ports

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 10250        | Kubelet API                     |
| TCP      | 30000-32767  | NodePort Services               |
| UDP      | 8472         | Flannel VXLAN overlay network   |

---

## Omero Web

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 4063         | Omero Web Service               |
| TCP      | 4064         | Omero Gateway                   |

---

## Omero Server

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 4061         | Omero Server (binary data transfer) |
| TCP      | 4062         | Omero Server (secondary data port) |

---

## Keycloak

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 8080         | Keycloak HTTP (Admin Console)   |
| TCP      | 8443         | Keycloak HTTPS                  |

---

## OpenLDAP

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 389          | Lightweight Directory Access Protocol (LDAP) |
| TCP      | 636          | Secure LDAP (LDAPS)             |

---

## PostgreSQL (Internal Only)

| Protocol | Port Range   | Purpose                         |
|----------|--------------|---------------------------------|
| TCP      | 5432         | PostgreSQL Database Server      |

> **Note**: It is not recommended to open the PostgreSQL port (5432) externally. This port should only be accessible within the internal network for security reasons.

---

## References

1. **OpenLDAP Ports**:
   - Official documentation: [LDAP and LDAPS](https://ldap.com/)
2. **Omero Ports**:
   - OME Documentation: [Omero Networking](https://docs.openmicroscopy.org/omero/)
3. **Keycloak Ports**:
   - Keycloak Documentation: [Server Configuration](https://www.keycloak.org/docs/latest/server_installation/)
4. **PostgreSQL Port**:
   - PostgreSQL Documentation: [PostgreSQL Networking](https://www.postgresql.org/docs/)
5. **Kubernetes Ports**:
   - Kubernetes Documentation: [Kubernetes Networking](https://kubernetes.io/docs/reference/ports-and-protocols/)
6. **Flannel VXLAN Port**:
   - Flannel Documentation: [Flannel Configuration](https://github.com/flannel-io/flannel)
7. **ngrok Ports**:
   - ngrok Documentation: [ngrok HTTP Tunnels](https://ngrok.com/docs)

---

### Notes:
1. **OpenLDAP** uses standard ports 389 (LDAP) and 636 (LDAPS).
2. **Omero Web** and **Omero Server** require ports 4061-4064 for binary data transfer and web services.
3. **Keycloak** runs on port 8080 for HTTP and 8443 for HTTPS.
4. **ngrok** exposes a web interface on port 4040 for managing tunnels.
5. **PostgreSQL** should not expose port 5432 externally. It is designed to be accessed internally within the network.
6. **Server Access** uses SSH (port 22) and HTTPS (port 443).
7. **Kubernetes Master and Worker Node Ports** are necessary for managing control plane and worker operations.
8. **Flannel VXLAN (UDP port 8472)** supports overlay networking for Kubernetes clusters.
