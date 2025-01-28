# Omero Data Portal

Welcome to the Omero Data Portal! Use the navigation links below to get started.

## Table of Contents

- [Prerequisites](#Prerequisites)
- [Installation](#installation)
  - [With Docker Compose](#installation-with-docker-compose)
  - [With Kubernetes](#installation-with-kubernetes)
- [Contribution](#contribution)

## Prerequisites

### 1. Running Instance
Ensure you have a **fully running instance** of **Ubuntu 22.04 LTS (Jammy)**.  
If your instance is not yet set up, refer to the [NectarVM Documentation](#) for detailed instructions on creating a new instance.

---

### 2. Open Ports
Make sure all necessary ports are open for proper communication. Refer to the [Ports Configuration Guide](port.md) for detailed instructions on configuring your ports.

---

### 3. Security Groups (For Cloud Users)
If you are using a cloud platform, it is recommended to create **separate security groups** for better management and security. Suggested security groups:
- **Omero**: For Omero-related components.
- **OIDC**: For OpenID Connect components.
- **Kubernetes Worker**: For Kubernetes worker nodes.
- **Kubernetes Control Planes**: For Kubernetes control planes.

Assigning separate security groups ensures isolation and better security compliance.

---

## Automated Package Installation

All necessary packages and dependencies will be downloaded and installed automatically using the provided script.

---

## Installation

To install OMERO, there are two methods available: using Docker Compose or Kubernetes. The choice depends on your scaling needs. For a single-instance setup, Docker Compose is recommended, while Kubernetes is ideal for multi-instance deployments. All prerequisites are covered in the guide, so no additional preparation steps are required beforehand.

### Installation with Docker Compose

Follow the [Docker Compose Installation Guide](https://github.com/DBK333/Omero-DataPortal/blob/main/DockerCompose.MD) to set up the Omero Data Portal using Docker Compose.

### Installation with Kubernetes

Follow the [Kubernetes Installation Guide](https://github.com/DBK333/Omero-DataPortal/blob/main/OmeroWithKubernetes.md) to set up the Omero Data Portal using Kubernetes.

---

## Contribution

We welcome contributions! Here are some resources to get you started:

- [Docker Example OMERO](https://github.com/ome/docker-example-omero)
- [Kubernetes OMERO](https://github.com/manics/kubernetes-omero)

Feel free to fork the repositories, submit issues, or create pull requests to help improve the project.
