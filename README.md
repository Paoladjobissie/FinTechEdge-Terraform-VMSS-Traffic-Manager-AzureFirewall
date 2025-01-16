# terraform-cloud-project
# FinTechEdge Terraform VMSS Traffic Manager AzureFirewall

## Project Overview

FinTechEdge is building a resilient, scalable, and secure infrastructure on Azure to support their customer-facing web application, expected to see high traffic. This project automates the deployment of a fully functional Azure infrastructure using Infrastructure as Code (IaC) with Terraform. The goal is to ensure high availability, security, cost management, and compliance, along with automated backups and disaster recovery.

---

## Project Objective

This project aims to deploy an Azure infrastructure that meets the following objectives:

1. **Identity & Access Management**  
   - Use Azure Active Directory (AAD) for user authentication and Role-Based Access Control (RBAC) for fine-grained access management.
   - Implement Multi-Factor Authentication (MFA) to enhance security for administrative tasks.

2. **Compute & Networking**  
   - Set up Virtual Machine Scale Sets (VMSS) for auto-scaling the web application across two Azure regions.
   - Configure Azure Load Balancer for distributing traffic efficiently between the VMSS instances.

3. **Storage & Data Protection**  
   - Create and configure Azure Blob Storage for storing application data.
   - Implement Azure Backup for automated backups of VMs and data.
   - Set up Azure Site Recovery for disaster recovery.

4. **Monitoring**  
   - Enable Azure Monitor and Log Analytics for tracking infrastructure performance.
   - Set up custom alerts for resource health and performance metrics.

5. **Automation**  
   - Use Azure Automation and CLI to manage infrastructure resources and automate routine tasks like VM scaling and health checks.

6. **Governance & Compliance**  
   - Enforce security and compliance policies using Azure Policy.
   - Set up Azure Cost Management and configure budget alerts to control spending.

---

## Key Deliverables

- **Terraform Scripts:** The entire infrastructure is deployed via Terraform scripts.
- **Documentation:** Instructions on setup, configuration, troubleshooting, and governance.
- **Screenshots:** Proof of successful setup, backups, failover tests, and policy enforcement.
- **GitHub Repository:** Contains the Terraform code and README.

---

## Setup Instructions

### Step 1: Identity & Access Management
1. **Create Azure AD Users & Groups:**
   - Define users and groups with roles (e.g., Admins, Developers, Viewers).
   - Use Azure RBAC to assign appropriate roles to users.

2. **Enable Multi-Factor Authentication (MFA):**
   - Apply Conditional Access policies to enforce MFA for critical access, such as administrative operations.

### Step 2: Configure Virtual Networks, VM Scale Sets, and Load Balancing
1. **Virtual Networks:**
   - Use Terraform to create two virtual networks in different regions (e.g., East US and West US).
   - Define subnets and configure Network Security Groups (NSGs) to control traffic between app and data subnets.

2. **VM Scale Sets (VMSS):**
   - Deploy VMSS instances with autoscaling based on CPU utilization.
   - Attach VMSS to an Azure Load Balancer to balance traffic across VM instances.

3. **Traffic Management:**
   - Set up Azure Traffic Manager to manage global traffic and ensure failover between East and West regions.

### Step 3: Configure Storage and Data Protection
1. **Azure Blob Storage:**
   - Deploy an Azure Storage Account and configure Blob Storage with geo-redundancy for high availability.

2. **Automate Backups:**
   - Configure Azure Backup to create and manage backups for VMs and Blob storage.

3. **Disaster Recovery:**
   - Set up Azure Site Recovery to replicate VMs to a secondary region for failover in case of a region failure.

### Step 4: Security & Compliance
1. **Deploy Azure Firewall & NSGs:**
   - Use Azure Firewall to control inbound and outbound traffic.
   - Use NSGs to enforce traffic rules between subnets.

2. **Enforce Governance with Azure Policy:**
   - Apply policies to restrict resource types, enforce region usage, and require specific tags for resource classification.

3. **Create Blueprints for Consistent Deployments:**
   - Define Azure Blueprints for environment consistency (e.g., Development, Production).

### Step 5: Monitoring and Alerts
1. **Enable Azure Monitor & Log Analytics:**
   - Set up Azure Monitor to collect metrics and logs from resources.
   - Create Log Analytics workspaces to centralize diagnostic data.

2. **Set Up Alerts:**
   - Configure alerts for key metrics like CPU usage, disk space, and network performance.
   - Use Azure Action Groups to notify administrators when thresholds are exceeded.

3. **Application Insights:**
   - Enable Application Insights to track application performance and capture any errors or bottlenecks in the web app.

### Step 6: Implement Automation
1. **Set Up Azure Automation Account:**
   - Create an Automation Account to run scripts and manage resources.

2. **Runbooks for Resource Management:**
   - Automate daily tasks like VM health checks, backups, and scaling operations using Azure Automation Runbooks.

3. **Azure CLI Commands in Runbooks:**
   - Use Azure CLI in automation to execute resource management tasks like scaling and backup verification.

### Step 7: Cost Management
1. **Set Up Azure Cost Management:**
   - Track resource usage and spending using Azure Cost Management.
   - Define budgets and set alerts for cost thresholds.

2. **Enable Resource Tagging:**
   - Apply tags to resources for better cost tracking, e.g., environment (Prod, Dev), department, and cost center.

---

## Terraform Scripts

The repository contains Terraform scripts that automate the deployment of:
- Azure AD and RBAC roles
- Virtual Networks, VMSS, and Load Balancer
- Azure Blob Storage and Backup configurations
- Firewall, NSGs, and Traffic Manager setup
- Monitoring and alert configurations
- Cost management policies

---

## Troubleshooting

- **Issue:** Terraform apply fails due to permission errors.
  - **Solution:** Ensure the Azure account running Terraform has sufficient permissions to create resources (e.g., Contributor or Owner role).

- **Issue:** Traffic Manager does not route traffic correctly.
  - **Solution:** Check the endpoint health and routing settings in Azure Traffic Manager to ensure proper failover configuration.

- **Issue:** Backups not running as expected.
  - **Solution:** Verify backup vault configurations, and check if schedules are correctly applied in the Azure Portal.

---

## Conclusion

This project leverages Terraform to automate the deployment of a secure, scalable, and cost-effective infrastructure on Azure for FinTechEdge. It includes essential services such as VM Scale Sets, Traffic Manager, Blob Storage, automated backups, monitoring, and disaster recovery.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

