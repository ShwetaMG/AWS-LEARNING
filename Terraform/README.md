# AWS Automated Web Architecture via Terraform (Infrastructure as Code)

## Project Overview
This repo is my hands-on implementation of an automated, highly available web architecture on AWS built entirely from scratch using Terraform. This Infrastructure as Code (IaC) project securely provisions a isolated network framework, launches automated web servers across multiple isolated Availability Zones, and manages live customer entry using a layer-7 Application Load Balancer.

## Architecture diagram
The diagram below illustrates the exact structural layout deployed via our code base:
```mermaid
graph TD
    %% External Ingress
    User((🌐 Internet User)) -->|Port 80| IGW[Internet Gateway]
    IGW --> RouteTable[Public Route Table]

    %% Infrastructure Boundaries
    subgraph VPC [Custom VPC Boundary]
        RouteTable --> ALB
        
        %% Load Balancing Component wrapped by Firewall
        subgraph SG_ALB [Security Group Protection]
            ALB[Application Load Balancer 'my-alb']
        end

        ALB --> TG[Target Group]

        %% Target Web Servers wrapped by Firewall
        subgraph SG_Instances [Security Group Protection]
            TG --> EC2_1[EC2 Instance 1: web-server-1]
            TG --> EC2_2[EC2 Instance 2: web-server-2]
        end
    end


```   


### Architectural Workflow:
1. **Isolated Routing Network**: A custom VPC provides a secure container for resources. An attached Internet Gateway routes external user calls into public paths.
2. **Cross-AZ Redundancy**: Subnets are divided dynamically across distinct geographical Availability Zones (`ap-south-1a` and `ap-south-1b`) to guarantee fault tolerance if an entire zone experiences downtime.
3. **Automated Server Provisioning**: EC2 instances run startup Bash script hooks (`user_data`) during setup phase to perform software updates, activate Apache HTTP services, capture system-level environment metadata, and compile customized index homepages.
4. **Traffic Balancing & Distribution**: An external Application Load Balancer accepts HTTP port 80 connections, tracks backend instance health pools via Target Group configurations, and alternates traffic to eliminate single points of failure.

---

## Repository Code Layout
* `providers.tf` / `main.tf` - Declares required provider plugins (pessimistic version pinning `~> 6.0`), core infrastructure resources (VPC, Subnets, Gateway, Route Tables, Security Group rules, EC2 targets, ALB parameters).
* `variables.tf` - Externalizes inputs like network CIDR block targets to ensure abstract modular adjustments.
* `userdata.sh` - Automated installation script deployed to instances on launch.
* `.gitignore` - Safeguards deployment tokens and local state configurations (`.terraform/`, `*.tfstate`).

---

## Core Resource Specifications

### 1. Networking Infrastructure
* **VPC**: Classless Inter-Domain Routing configured for `10.0.0.0/16`.
* **Public Subnets**: Two decoupled subnets (`10.0.0.0/24` and `10.0.1.0/24`) configured to assign public IPs to instances automatically on launch.
* **Routing**: A centralized Route Table directing all global outbound tracking (`0.0.0.0/0`) straight to the Internet Gateway.

### 2. Security Configuration
Inbound firewall parameters (`aws_security_group`) lock access to necessary vector profiles:
* **Inbound (Ingress)**: Port `80` (HTTP) open worldwide for user requests, and Port `22` (SSH) open for administrative system connections.
* **Outbound (Egress)**: Port `0` fully open to all external targets for seamless packaging installations.

### 3. Load Balancer Components
* **Application Load Balancer**: External, internet-facing layer-7 controller connected across both Availability Zones.
* **Target Group**: Deployed on Port 80 tracking automatic HTTP root `/` health tests.
* **Listener Rule**: Forwards universal global web actions straight into the active instance pool.

---

## How to Initialize and Deploy Locally

### Prerequisites
1. Installed **Terraform CLI** configured in system binary environment paths.
2. Local **AWS CLI** configured via `aws configure` using secure IAM credentials.

### Deployment Commands
Clone the directory, open your command terminal inside the root path, and execute:

```bash
# 1. Initialize the project to download the AWS provider plugins
terraform init

# 2. Format and validate codebase syntax rules
terraform fmt
terraform validate

# 3. Perform a dry-run to preview actions before applying changes
terraform plan

# 4. Spin up the entire infrastructure stack directly onto AWS
terraform apply -auto-approve
```

Once deployment concludes, copy the generated load balancer DNS address string printed in the terminal outputs to observe live round-robin load distribution across the web nodes.

---

## Cleanup Infrastructure

To ensure zero ongoing charges for instructional test blocks, tear down all active components automatically using:
```bash
terraform destroy -auto-approve
```

