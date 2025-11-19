# Minikube Deployment on Azure with Fedora 43, Podman, Rootless Containerd, Traefik 3.6 & Let's Encrypt

This repository automates the deployment of a full Minikube environment on an Azure virtual machine.  
The entire stack runs **rootless** using Podman and Containerd, provides ingress and load balancing through **Traefik 3.6**, and is fully deployed via **Ansible**.

The example website is hosted here:  
https://github.com/dhojnik/sample_website  
and becomes available at:  
https://yeah.example.com

---

# Overview

- Azure provisioning using **Python 3.10** and Azure SDK  
- Deployment automation with Ansible  
- Fedora 43 VM running:
  - Rootless Podman  
  - Rootless Containerd  
  - slip4netns network  
- Minikube cluster  
- 3 webserver containers with Kubernetes health probes  
- Traefik 3.6 reverse proxy + load balancer  
- Let's Encrypt TLS certificate automation  
- Website content dynamically loaded from a Git repo via environment variable  

---

# Architecture

```text
Azure VM (Fedora 43)
│
├─ Rootless User Environment
│   ├─ Podman (rootless)
│   ├─ Containerd (rootless)
│   └─ slip4netns networking
│
├─ Minikube Cluster
│   ├─ 3 Webserver Containers
│   │   ├─ Pull website content dynamically from Git repo (ENV variable)
│   │   └─ Health: Kubernetes Liveness & Readiness Probes
│   │
│   └─ Traefik 3.6
│       ├─ Reverse Proxy
│       ├─ Round-Robin Load Balancer
│       ├─ Probe-based Failover
│       └─ Automatic Let's Encrypt TLS
│
└─ Deployment Automation
    ├─ Python 3.10 + Azure SDK packages
    ├─ playbook_environment_delete.yml → Create/delete Azure VM
    └─ playbook_deploy_minicube.yml → Configure VM + deploy Minikube
```

---

# Requirements

- **Python 3.10**  
  (Azure SDK currently only runs with Python 3.10)  
- SSH key  
- Azure subscription  
- Ansible Core 2.18.3  
- Git  

---

# Python / Azure Environment Setup

Azure SDK modules are installed via `requirements.txt` and must run under **Python 3.10**.

## Install

```bash
pip install --upgrade pip
pip install -r azure-requirements.txt
pip install ansible
```

```

All versions are tested and compatible with Python **≤ 3.10**.

---

# Azure VM Provisioning

The Azure VM is created using:

### Create environment

```bash
ansible-playbook playbook_environment_delete.yml
```

This playbook manages:

- Resource Group  
- Virtual Machine  
- Networking (VNet, subnet, IP, NSG)  

---

# Deploying Minikube on the VM

Once the VM is up, Minikube is installed with:

```bash
ansible-playbook playbook_deploy_minicube.yml
```

This playbook performs:

- os updates
- a basic install about tools and minicube
- initial firewall configuration

- Rootless user setup  
- Podman + Containerd rootless configuration  
- slip4netns networking  
- Installation and start of Minikube  
- Deployment of:
  - Webserver containers  
  - Kubernetes manifests  
  - Traefik 3.6  
  - Let's Encrypt certificates  

---

# Website Loading from Git Repository

Each container loads its website content dynamically from a Git repository using an environment variable:

```yaml
env:
  - name: GIT_REPO_URL
    value: "https://github.com/dhojnik/sample_website"
```

The content is cloned when the container starts.

---

# Kubernetes Health Checks

Health checks are **exclusively performed by Kubernetes probes**, not by endpoints inside the container.

Example:

```yaml

  initialDelaySeconds: 5
  periodSeconds: 10

```

Or using TCP:

```yaml
livenessProbe:
  tcpSocket:
    port: 8080
```

➡ Unhealthy pods should get automatically removed from Traefik routing.

---

# Load Balancing with Traefik 3.6

Traefik performs:

- Reverse proxying  
- Round-robin load balancing  
- Failover based on Kubernetes readiness probes  
- Automatic Let's Encrypt TLS certificates  

---

# HTTPS with Let's Encrypt

Traefik uses Let's Encrypt to generate valid HTTPS certificates.

The service becomes available at:

**https://yeah.example.com**

---

# Cleaning Up Infrastructure

```bash
ansible-playbook playbook_environment_delete.yml
```

This removes:

- VM  
- Public IP  
- Network components  
- Resource Group (if configured)  

---

#  License

BSD License  
© 2025
