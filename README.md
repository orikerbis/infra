# Infrastructure Repository

This repository manages the cloud infrastructure for our platform, built using **Terraform**. It provisions resources on AWS, including an **EKS cluster**, **VPC**, and additional services such as **Karpenter**, **ArgoCD**, and **Nginx Ingress Controller**. The repository is designed to support multiple environments (e.g., `dev`, `test`, `prod`) and includes modular and reusable Terraform configurations.

---

## Directory Structure
``` plaintext
.
├── README.md
├── environments
│   ├── dev
│   │   ├── backend.tf
│   │   └── main.tf
│   ├── prod
│   └── test
├── platform
│   ├── acm.tf
│   ├── argocd.tf
│   ├── eks.tf
│   ├── mongodb.tf
│   ├── nginx.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── vpc.tf
└── terraform.tfstate
```
---

## Key Features

### 1. **EKS Cluster**
- **Provisioned in a custom VPC** using Terraform.
- **Two managed node groups**:
  - One dedicated to **Karpenter**, the autoscaling solution for Kubernetes.
  - One dedicated to the **MongoDB StatefulSet**.

### 2. **AWS Load Balancer Controller**
- Listens for Kubernetes **Ingress resources** with the `alb` class.
- Automatically provisions an **Application Load Balancer (ALB)** in AWS for public-facing traffic.

### 3. **Nginx Ingress Controller**
- Configured as an **internal load balancer**.
- Routes requests from the AWS ALB to specific Kubernetes services based on ingress rules.

### 4. **Helm Chart Deployments**
- Uses Helm to deploy:
  - **ArgoCD**: For GitOps-based continuous delivery.
  - **Nginx Ingress Controller**: For internal traffic routing.
  - **Karpenter**: For efficient autoscaling of Kubernetes workloads.
  - **prometheus-stack**: For monitoring the infrastracture
  - **MongoDB**: For storing the data. I've used a EBS-CSI driver to store all the data in an external block storage for data protection.

### 5. **MongoDB and Secret Management**
- **MongoDB StatefulSet** deployed in the EKS cluster.
- A random password for MongoDB is generated using Terraform and stored securely in **AWS Secrets Manager**.
- **External Secrets** integration allows Kubernetes to inject the MongoDB password directly into the application at runtime.

---

## Environments

The repository supports multiple environments (`dev`, `test`, `prod`), each with its own configuration:

- **Environment Structure**:
  - `backend.tf`: Configures the remote state backend for storing Terraform state.
  - `main.tf`: Specifies environment-specific variables and invokes the platform module.

