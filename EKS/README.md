# AWS EKS Core Infrastructure & Ingress Management

This repository documents my hands-on implementation of an Amazon EKS (Elastic Kubernetes Service) cluster, focusing on setting up AWS IAM Roles for Service Accounts (IRSA) to dynamically provision an AWS Application Load Balancer via the AWS Load Balancer Controller.

## 🎓 Acknowledgments & Credits
* **Tutorial Source:** This practical project was built following the excellent guide **"Kubernetes End to End project on EKS"** by DevOps Educator **Abhishek Veeramalla** as part of his *AWS DevOps Zero to Hero* series. 
* **Reference Tutorial:** [Watch the YouTube Video Here](https://youtu.be/RRCrY12VY_s?si=mxdWS16xq28D5DwA)
* **Debugging & AI Collaboration:** Special thanks to my AI collaborator, **Gemini**, for serving as a peer debugging partner to analyze cloud stack rollbacks and trace invalid API schemas.

## 🗺️ Cluster Architecture Diagram

```mermaid
graph TD
    User([Internet Traffic / User]) -->|HTTP/HTTPS| ALB[AWS Application Load Balancer]
    
    subgraph AWS Cloud [Amazon Web Services]
        subgraph EKS Cluster [Amazon EKS Cluster Control Plane]
            LBC[AWS Load Balancer Controller Pod]
            MS[Metrics Server Pod]
            CD[CoreDNS Pod]
        end
        
        subgraph Data Plane [Fargate / Managed Nodes]
            AppPods[Application Pods]
        end

        subgraph Security & Access [IAM & Identity]
            OIDC[OIDC Identity Provider]
            IAMRole[IAM Role: AmazonEKSLoadBalancerControllerRole]
            SA[K8s Service Account: aws-load-balancer-controller]
        end
    end

    ALB -->|Routes Traffic| AppPods
    LBC -->|1. Watches Ingress| AppPods
    LBC -->|2. Assumes via OIDC| IAMRole
    IAMRole -->|3. Dynamically Provisions| ALB
    SA -.->|Bound to| IAMRole

---

## 🛠️ Tech Stack & Prerequisites
* **Cloud Provider:** AWS (EKS, IAM, CloudFormation, EC2)
* **CLI Tools:** AWS CLI, `kubectl`, `eksctl`, `Helm`
* **Orchestration:** Kubernetes



## 🗺️ Architecture Workflow
1. **Cluster Provisioning:** Initialized an EKS cluster using `eksctl` with a managed control plane and Fargate serverless data plane profiles.
2. **OIDC Identity Provider:** Configured an OpenID Connect (OIDC) issuer for the cluster to allow Kubernetes service accounts to securely authenticate with AWS IAM.
3. **IAM Policy Creation:** Established a specialized IAM Policy specifying the routing and discovery permissions required by an Application Load Balancer.
4. **Service Account Binding:** Utilized `eksctl` to bridge the Kubernetes `aws-load-balancer-controller` service account with an AWS IAM role.
5. **Helm Deployment:** Deployed the active AWS Load Balancer Controller to dynamically watch Ingress resources and manage live AWS Application Load Balancers (ALB).



## 🔍 Troubleshooting & Key Learnings (The Gemini Debug Sessions)

While keeping pace with the video steps, I ran into a classic infrastructure roadblock that wasn't natively covered in the walkthrough. Working alongside Gemini, we systematically broken down the failure:

### 1. Resolving CloudFormation Stack Stalls (`ROLLBACK_COMPLETE`)
* **The Issue:** The `eksctl create iamserviceaccount` command repeatedly errored out on execution. Checking the AWS CloudFormation timeline, a nested resource called `Role1` kept throwing a `CREATE_FAILED` error, automatically triggering a total stack rollback.
* **The Root Cause:** CloudFormation entered a locked state. Gemini helped trace the logs to find the exact validator error string: `ARN arn:aws:iam::<ACCOUNT_ID>:policy/... is not valid.` This meant the IAM user permissions were completely fine, but there was an explicit validation/format mismatch in the underlying terminal string payload.
* **The Solution:** 1. Manually purged the stale, locked stack stubs from the AWS CloudFormation Dashboard.
  2. Extracted the absolute, raw verified ARN directly out of the AWS IAM Policies console window.
  3. Re-executed the setup by passing the `--override-existing-serviceaccounts` flag to force-clear cluster metadata tracking.

### 2. Identifying Default Cluster Services
* **The Learning:** Upon verifying the health of the system via `kubectl get deploy -n kube-system`, I noticed a `metrics-server` deployment active that wasn't explicitly mentioned at that point in the tutorial. Gemini clarified that modern iterations of `eksctl` bundle lightweight, cluster-wide metric aggregators directly during bootstrap to natively enable HPA (Horizontal Pod Autoscaling) out of the box.

