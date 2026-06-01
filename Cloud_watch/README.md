# AWS CloudWatch Deep Dive: EC2 Metric Monitoring & Alarm Automation

This repository contains the hands-on project documentation and source code for setting up real-time infrastructure monitoring on AWS. In this demo, an automated CPU utilization monitoring system was established for an Amazon EC2 instance using AWS CloudWatch, which triggers instant email alerts via Amazon Simple Notification Service (SNS) whenever metric thresholds are crossed.

---

## 🏗️ Architecture Overview

The monitoring pipeline operates dynamically across the following AWS services:
1. **Amazon EC2:** Host instance where workloads run and metrics are generated.
2. **AWS CloudWatch Metrics:** Collects hypervisor-level data point observations (e.g., CPU Utilization) from the instance.
3. **AWS CloudWatch Alarms:** Evaluates the continuous metric streams against a static threshold.
4. **Amazon SNS (Simple Notification Service):** Receives the alarm state transition action and broadcasts a localized email alert to subscribed administrators.

---

## 🛠️ Project Implementation Steps

### 1. EC2 Provisioning & Detailed Monitoring
* Launched an Ubuntu-based **T2 Micro** EC2 instance target.
* **Crucial Step:** Navigated to the instance's **Monitoring** properties and chose *Manage Detailed Monitoring* to turn on **1-Minute Period Interval Metrics** (default standard monitoring pushes data every 5 minutes). This enables rapid, real-time alert triggers during infrastructure stress spikes.

### 2. Simple Notification Service (SNS) Topic Setup
* Created a standard SNS notification channel named `CloudWatch-Topic`.
* Added an email subscription endpoint targeting the systems administrator mailbox.
* Confirmed the registration by opening the system-generated activation email containing the **"Confirm Subscription"** link to move the status from *Pending Confirmation* to *Confirmed*.

### 3. Creating the CloudWatch Alarm
* Selected the **Per-Instance Metrics** category from the `AWS/EC2` namespace.
* Isolated the target instance matching the deployed Resource ID.
* Configured the metric query parameters:
  * **Metric Name:** `CPUUtilization`
  * **Statistic:** `Maximum` (Evaluates the highest observed metric peak within the time frame)
  * **Period:** `1 minute`
* Defined threshold condition limits:
  * **Threshold type:** Static
  * **Condition:** Greater than or equal to (`>=`) **40%**
* Mapped the Action State trigger configuration to pass notifications over to the `CloudWatch-Topic` SNS channel whenever the system evaluates into the `ALARM` state.

### 4. Simulating the Infrastructure CPU Load Spike
Connected to the live EC2 instance via the terminal and executed the `cpu_spike.py` script located in this repository to artificially raise resource consumption and breach the 40% threshold.

🎯 Verification and Project Results
Metric Tracking: The execution of the continuous processing script successfully simulated an intense environment spike, pushing baseline core utilization limits past the configured 40% threshold.

Alarm Triggering: CloudWatch correctly detected the breaching data points within the 1-minute tracking interval, transitioning the status marker seamlessly from OK to In ALARM.

Email Notification Delivery: The active SNS topic intercepted the breach state notification and successfully dispatched an automated email message right into the subscribed inbox detailing the target resource, timestamp, and exception telemetry values.

## Demo screenshots

![CloudWatch Metric Graph](Cloud_watch\images\screenshot_metrix.png)

![Alaram notification in inbox](Cloud_watch\images\screenshot_notif.png)

NOTE: I performed this demo by watching Abhishek veermallas AWS-zero-to-hero series from youtube channel. please go through the vedio if you want to understand clearly.