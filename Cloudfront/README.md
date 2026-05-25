# Secure Static Website cum Techblog page Hosting using Amazon S3 and CloudFront

## 📌 Project Overview
This repository contains the configuration and documentation for deploying a highly available, secure, and fast static website on AWS. The architecture leverages **Amazon S3** for storage and **Amazon CloudFront** as a Content Delivery Network (CDN) to serve content globally with low latency.

## 🏗️ Architecture & Security Design
To follow AWS security best practices, the infrastructure is designed as follows:
* **Private S3 Bucket:** Public access to the S3 bucket is completely disabled. The data is not exposed directly to the internet.
* **Origin Access Control (OAC):** CloudFront is configured with OAC, allowing only authorized CloudFront edge locations to fetch objects from the private S3 bucket using an explicit bucket policy.
* **Caching:** Content is cached globally at AWS edge locations, reducing data transfer costs and server load on the origin bucket.

## 🚀 Step-by-Step Implementation

### Step 1: Storage Setup (Amazon S3)
1. Created an Amazon S3 bucket.
2. Enabled **Block *all* public access** to secure the bucket.
3. Uploaded the static website files (`index.html`) to the root of the bucket.

### Step 2: Content Delivery Setup (Amazon CloudFront)
1. Created a CloudFront web distribution pointing to the S3 bucket origin.
2. Configured **Origin Access Control (OAC)** to generate a secure service principal identity for CloudFront.
3. Set the **Default Root Object** to `index.html`.

### Step 3: Security & Permissions Integration
1. Attached a custom **IAM Bucket Policy** to the S3 bucket allowing `s3:GetObject` actions only when the request originates from this specific CloudFront distribution's Amazon Resource Name (ARN).

## 🧪 Verification & Testing
To verify that the setup works exactly as intended, I performed the following validation tests:
1. **CloudFront Access (Success):** Accessed the website via the CloudFront distribution domain URL (`https://dxxxxx.cloudfront.net/`), and the page loaded successfully.
2. **S3 Direct Access (Blocked):** Attempted to access the file directly via the S3 Object URL, resulting in a successful `AccessDenied` error. This confirms the bucket remains strictly private.
3. **Cache Verification:** Checked the browser's Network tab headers to verify the `X-Cache` response header showed a `Hit from cloudfront`, confirming edge location caching is active.