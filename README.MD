# Omero Data Portal

Welcome to the Omero Data Portal! Use the navigation links below to get started. The fully operational scripts include the installation of Omero with Docker Compose and OIDC. Meanwhile, the Omero installation with Kubernetes is currently a conceptual guideline for production-scale deployment.

The OMERO with OIDC installation is still under development.

## Table of Contents

- [Prerequisites](#prerequisites)
  - [OMERO Image Samples](#omero-image-samples)
  - [Running Instance](#running-instance)
  - [Security](#security)
  - [Security Groups (For Cloud Users)](#security-groups-for-cloud-users)
- [Automated Package Installation](#automated-package-installation)
- [Installation](#installation)
  - [OMERO Installation with Docker Compose](#omero-installation-with-docker-compose)
  - [OMERO Installation with Kubernetes](#omero-installation-with-kubernetes)
  - [Installation with OIDC Components Only](#installation-with-oidc-components-only)
  - [OMERO Installation with OIDC](#omero-installation-with-oidc)
- [OMERO Functions](#omero-functions)
  - [OMERO Data Upload](#omero-data-upload)
  - [OMERO Access Controls](#omero-access-controls)
- [Contribution](#contribution)
- [License](#license)
- [References](#references)

---

## Prerequisites

### OMERO Image Samples

Explore various OMERO image samples to get started:

- [Browse OMERO Samples](https://github.com/DBK333/Omero-DataPortal/tree/main/OmeroImageSamples)

---

### Running Instance

Ensure you have a **fully running instance** of **Ubuntu 22.04 LTS (Jammy)**.

If your instance is not yet set up, refer to the [NectarVM Documentation](https://nectarvm.example.com/documentation) for detailed instructions on creating a new instance.

---

### Security

Make sure all necessary ports are open for proper communication. Refer to the [Security and Ports Configuration Guide](https://github.com/DBK333/Omero-DataPortal/blob/main/SECURITY.MD) for detailed instructions on configuring your ports.

---

### Security Groups (For Cloud Users)

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

### OMERO Installation with Docker Compose

Follow the [Docker Compose Installation Guide](https://github.com/DBK333/Omero-DataPortal/blob/main/InstallationDockerCompose) to set up the Omero Data Portal using Docker Compose.

### OMERO Installation with Kubernetes

Follow the [Kubernetes Installation Guide](https://github.com/DBK333/Omero-DataPortal/tree/main/InstallationKubernetes) to set up the Omero Data Portal using Kubernetes.

### Installation with OIDC Components Only

Follow the [OIDC for Component Only Installation Guide](https://github.com/DBK333/Omero-DataPortal/tree/main/InstallationOIDC) to integrate OpenID Connect authentication with the Omero Data Portal using Kubernetes.

### OMERO Installation with OIDC

**Note:** You must install OMERO first before setting up OIDC.

Follow the [OMERO with OIDC Installation Guide](https://github.com/DBK333/Omero-DataPortal/tree/main/InstallationOmeroWithOIDC) to integrate OpenID Connect authentication with the Omero Data Portal using Docker Compose.

---

## OMERO Functions

### OMERO Data Upload

Method on how to upload data into OMERO from your device:

- [Omero Data Upload](https://github.com/DBK333/Omero-DataPortal/blob/main/DATAUPLOAD.MD)

---

### OMERO Access Controls

Method on how to use Access Control with OMERO.web from your browser:

- [Omero Access Control](https://github.com/DBK333/Omero-DataPortal/blob/main/DATAACCESS.MD)

---

## Contribution

We welcome contributions! Here are some resources to help you get started:

- [Docker Example OMERO](https://github.com/ome/docker-example-omero)
- [Kubernetes OMERO](https://github.com/manics/kubernetes-omero)

Feel free to fork the repositories, submit issues, or create pull requests to help improve the project.

---

## License

This repository is licensed under the terms specified in the [LICENSE](LICENSE) file.

---

## References

1. OMERO Project Documentation: https://www.openmicroscopy.org/omero/
2. NectarVM Documentation: https://nectarvm.example.com/documentation
3. Docker Example OMERO: https://github.com/ome/docker-example-omero
4. Kubernetes OMERO: https://github.com/manics/kubernetes-omero
5. Security Configuration Guide: https://github.com/DBK333/Omero-DataPortal/blob/main/SECURITY.MD
