# AWS Automated Web Architecture via Terraform (Infrastructure as Code)

## Project Overview
This repo is my hands-on implementation of an automated, highly available web architecture on AWS built entirely from scratch using Terraform. This Infrastructure as Code (IaC) project securely provisions a isolated network framework, launches automated web servers across multiple isolated Availability Zones, and manages live customer entry using a layer-7 Application Load Balancer.

## Architecture diagram
The diagram below illustrates the exact structural layout deployed via our code base:
```mermaid
dth:2px,stroke-dasharray: 5 5graph TD
    %% External User Client
    User((🌐 Internet User)) -->|HTTP Request: Port 80| IGW

    %% AWS Cloud Infrastructure
    subgraph AWS_Cloud ["AWS Cloud (Region: us-east-1)"]
        
        subgraph VPC ["Custom VPC (10.0.0.0/16)"]
            
            %% Edge Ingress Layer
            IGW[Internet Gateway] -->|Routes Traffic| RouteTable[Public Route Table]
            RouteTable -->|Directs to| ALB
            
            %% Application Load Balancer
            ALB[Application Load Balancer <br> 'my-alb']
            
            %% Routing to Target Group
            TG[Target Group <br> Port 80 / Health Check: /]
            ALB -->|Forwards Traffic| TG

            %% Availability Zone A
            subgraph AZ_A ["Availability Zone: us-east-1a"]
                subgraph Subnet_1 ["Public Subnet 1 (10.0.0.0/24)"]
                    EC2_1["EC2 Instance 1 <br> 'web-server-1' <br> (Apache HTTP Server)"]
                end
            end

            %% Availability Zone B
            subgraph AZ_B ["Availability Zone: us-east-1b"]
                subgraph Subnet_2 ["Public Subnet 2 (10.0.1.0/24)"]
                    EC2_2["EC2 Instance 2 <br> 'web-server-2' <br> (Apache HTTP Server)"]
                end
            end
            
            %% Target Group Associations
            TG --> EC2_1
            TG --> EC2_2

            %% Shared Security Firewall Layer
            SG{Web Security Group <br> Inbound: 80, 22 <br> Outbound: ALL}
            EC2_1 -.-> SG
            EC2_2 -.-> SG
            ALB -.-> SG

        end
    end

    %% Visual Styling
    style User fill:#f9f,stroke:#333,stroke-width:2px
    style ALB fill:#4D90FE,stroke:#fff,stroke-width:2px,color:#fff
    style TG fill:#FF9900,stroke:#fff,stroke-width:2px,color:#fff
    style IGW fill:#FF9900,stroke:#fff,stroke-width:2px,color:#fff
    style RouteTable fill:#cc99ff,stroke:#333,stroke-width:1px
    style EC2_1 fill:#FF9900,stroke:#333,stroke-width:1px
    style EC2_2 fill:#FF9900,stroke:#333,stroke-width:1px
    style SG fill:#cc0000,stroke:#fff,stroke-width:1px,color:#fff
    style VPC fill:#f5f5f5,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5
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