# Omero Data Portal

Welcome to the **Omero Data Portal**! Use the navigation links below to get started.

## Table of Contents

- [Prerequisites](#prerequisites)
  - [1. Running Instance](#1-running-instance)
  - [2. Security](#2-security)
  - [3. Security Groups (For Cloud Users)](#3-security-groups-for-cloud-users)
- [Automated Package Installation](#automated-package-installation)
- [Installation](#installation)
  - [With Docker Compose](#installation-with-docker-compose)
  - [With Kubernetes](#installation-with-kubernetes)
  - [With OIDC](#installation-with-oidc)
  - [OMERO Image Samples](#omero-image-samples)
- [Contribution](#contribution)
- [License](#license)

---

## Prerequisites

### 1. Running Instance

Ensure you have a **fully running instance** of **Ubuntu 22.04 LTS (Jammy)**.

If your instance is not yet set up, refer to the [NectarVM Documentation](https://nectarvm.example.com/documentation) for detailed instructions on creating a new instance.

---

### 2. Security

Make sure all necessary ports are open for proper communication. Refer to the [Security and Ports Configuration Guide](SECURITY.md) for detailed instructions on configuring your ports.

---

### 3. Security Groups (For Cloud Users)

If you are using a cloud platform, it is recommended to create **separate security groups** for better management and security. Suggested security groups:

- **Omero**: For Omero-related components.
- **OIDC**: For OpenID Connect components.
- **Kubernetes Worker**: For Kubernetes worker nodes.
- **Kubernetes Control Planes**: For Kubernetes control planes.

Assigning separate security groups ensures isolation and enhances security compliance.

---

## Automated Package Installation

All necessary packages and dependencies will be downloaded and installed automatically using the provided script. Please follow the guidelines given in each [installation section](#installation) for detailed instructions.

---

## Installation

To install OMERO, there are three methods available: using Docker Compose, Kubernetes, or integrating with OIDC. The choice depends on your scaling needs and authentication requirements.

- **Docker Compose**: Recommended for single-instance setups.
- **Kubernetes**: Ideal for multi-instance deployments.
- **OIDC Integration**: For enhanced authentication mechanisms.

All prerequisites are covered in the [Prerequisites](#prerequisites) section, so no additional preparation steps are required beforehand.

### Installation with Docker Compose

Follow the [Docker Compose Installation Guide](InstallationDockerCompose/README.md) to set up the Omero Data Portal using Docker Compose.

### Installation with Kubernetes

Follow the [Kubernetes Installation Guide](InstallationKubernetes/README.md) to set up the Omero Data Portal using Kubernetes.

### Installation with OIDC

**Note:** You must install OMERO first before setting up OIDC.

Follow the [OIDC for OMERO Installation Guide](InstallationOIDC/README.md) to integrate OpenID Connect authentication with the Omero Data Portal using Kubernetes.

### OMERO Image Samples

Explore various OMERO image samples to get started:

- [Browse OMERO Samples](OmeroImageSamples/README.md)

---

## Contribution

We welcome contributions! Here are some resources to help you get started:

- [Docker Example OMERO](https://github.com/ome/docker-example-omero)
- [Kubernetes OMERO](https://github.com/manics/kubernetes-omero)

Feel free to fork the repositories, submit issues, or create pull requests to help improve the project.

---

## License

This repository is licensed under the terms specified in the [LICENSE](LICENSE) file.
