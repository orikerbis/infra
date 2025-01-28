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

```
---

## Key Features

### 1. **VPC Design**

The **Virtual Private Cloud (VPC)** is a custom networking environment where all AWS resources, including the EKS cluster, reside. The VPC is designed to ensure security, scalability, and high availability:

- **Subnets**:
- **Private Subnets**: The EKS cluster is deployed entirely within private subnets, ensuring that the cluster nodes and workloads are not directly accessible from the internet.
- **Public Subnets**: Used for internet-facing resources such as the ALB (Application Load Balancer) provisioned by the AWS Load Balancer Controller.

- **Internet Gateway**:
- Attached to the VPC to enable resources in public subnets (e.g., ALB) to access the internet.

- **NAT Gateways**:
- Used to allow resources in private subnets (e.g., EKS nodes) to access the internet securely (e.g., for pulling container images or updating software) without exposing them to incoming traffic.
- A NAT Gateway is deployed in each availability zone for redundancy.

- **Routing**:
  - Public subnets route traffic to the internet via the Internet Gateway.
  - Private subnets route traffic through the NAT Gateways for outbound internet access.


### 2. **EKS Cluster**
- **Provisioned in a custom VPC** using Terraform.
- **Two managed node groups**:
  - One dedicated to **Karpenter**, the autoscaling solution for Kubernetes.
  - One dedicated to the **MongoDB StatefulSet**.

### 3. **AWS Load Balancer Controller**
- Listens for Kubernetes **Ingress resources** with the `alb` class.
- Automatically provisions an **Application Load Balancer (ALB)** in AWS for public-facing traffic.

### 4. **Nginx Ingress Controller**
- Configured as an **internal load balancer**.
- Routes requests from the AWS ALB to specific Kubernetes services based on ingress rules.

### 5. **Domain Name and HTTPS Setup**

- **Domain Name**:
  - The platform is accessible via a custom domain name (e.g., `example.com`).

- **SSL Certificate**:
  - An **AWS Certificate Manager (ACM)** certificate is provisioned automatically for the domain name.
  - Enables secure HTTPS connections for the platform.

- **ACM Module**:
  - A reusable ACM module is implemented in the `platform/` directory to automate the creation of SSL certificates for the domain.
  - Automatically validates the domain using DNS validation through Route 53.

- **ALB Alias Record**:
  - An **Alias Record** is created in **Amazon Route 53** to map the domain name to the Application Load Balancer (ALB).
  - This ensures that all traffic to the domain is routed to the ALB, which then forwards it to the internal Nginx Ingress Controller for routing to Kubernetes services.


### 6. **Helm Chart Deployments**
- Uses Helm to deploy:
  - **ArgoCD**: For GitOps-based continuous delivery.
  - **Nginx Ingress Controller**: For internal traffic routing.
  - **Karpenter**: For efficient autoscaling of Kubernetes workloads.
  - **prometheus-stack**: For monitoring the infrastracture
  - **MongoDB**: For storing the data. I've used a EBS-CSI driver to store all the data in an external block storage for data protection.

### 7. **MongoDB and Secret Management**
- **MongoDB StatefulSet** deployed in the EKS cluster.
- A random password for MongoDB is generated using Terraform and stored securely in **AWS Secrets Manager**.
- **External Secrets** integration allows Kubernetes to inject the MongoDB password directly into the application at runtime.

---

## Environments

The repository supports multiple environments (`dev`, `test`, `prod`), each with its own configuration:

- **Environment Structure**:
  - `backend.tf`: Configures the remote state backend for storing Terraform state.
  - `main.tf`: Specifies environment-specific variables and invokes the platform module.

## About the Project

This repository is **one of three repositories** that together form the complete platform:

1. **Infrastructure Repository (This Repository)**:
   - Manages cloud infrastructure using Terraform.
   - Provisions resources such as EKS, VPC, AWS Load Balancer Controller, Nginx, and more.

2. **GitOps Repository**:
   - Manages Kubernetes deployments using a GitOps approach with **ArgoCD**.
   - Tracks application Helm charts and Kubernetes manifests.

3. **Application Repository**:
   - Contains the application codebase, Dockerfiles, and CI/CD pipelines for building and deploying the app.

These repositories are designed to work together, providing a modular and scalable platform.

---
