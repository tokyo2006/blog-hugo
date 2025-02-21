---
date: 2025-02-21
title: "Summary of Interviews"
description: "This will record all the problems encountered in interviews."
Type: "presentation"
Tags:
 - interview
 - devops 
---

## Problem Record

---

### Question 1: How to determine the rules that need to be set in WAF?

**Answer:** Determining the rules that need to be set in a Web Application Firewall (WAF) typically involves considering the following aspects:

Commonly used methods include:
1. **Security Requirements**: Based on the organization's security policies and business needs, identify which web applications and resources require protection.
2. **Compliance**: Ensure that WAF rules comply with relevant security standards and regulations.
3. **Attack Detection**: Understand common types of web application attacks and set corresponding rules to detect and block these attacks.
4. **Performance Impact**: Consider the impact on web application performance when setting rules, avoiding excessive restrictions on legitimate traffic.

Further refinement can be done based on actual business scenarios, such as:
- Restricting access to specific resources using IP whitelists or blacklists (using monitoring alerts as data sources).
- Protecting against common attacks like SQL injection and Cross-Site Scripting (XSS).

---

### Question 2: Why migrate previous services to Kubernetes?

**Answer:** Migrating previous services to Kubernetes offers several benefits:

- **Ease of Management**: Traditional services require configuration management tools (e.g., Ansible, Puppet) to manage service configurations and infrastructure. Kubernetes provides a unified platform for managing applications and services, simplifying configuration and management processes.
- **High Availability**: By deploying multiple Pod replicas, Kubernetes ensures that services remain available even if a node fails.
- **Resource Optimization**: Kubernetes utilizes cluster resources more efficiently, avoiding waste.
- **Ease of Scaling**: As the business grows, it is easy to add more nodes to the Kubernetes cluster to support additional application instances.

---

### Question 3: How does ArgoCD achieve automated deployment of services?

**Answer:**
1. Store all service deployment configurations in a monorepo and set up the service scan path.
2. Add `applicationset.yaml` files for each service in the specified directory, defining the Helm repository address and related property repository addresses.
3. When service code changes, trigger updates to the application set by updating the version property repository through CI processes. ArgoCD automatically pulls the latest application set configuration and performs the deployment.
4. To roll back, simply submit a PR to update the version file in the property repository to quickly implement the rollback.

---

### Question 4: How to achieve horizontal scaling of services in Kubernetes?

**Answer:** Horizontal scaling of services in Kubernetes is typically achieved using Horizontal Pod Autoscaler (HPA). HPA automatically adjusts the number of Pods based on CPU usage, memory usage, or other custom metrics to ensure that the service can handle expected loads.

---

### Question 5: Why use an independent VPC for each account?

**Answer:** Using an independent Virtual Private Cloud (VPC) for each account provides a range of significant advantages, enhancing security, management efficiency, and resource isolation:

1. **Enhanced Security**: An independent VPC allows for more granular configuration of security policies. For example, it is easier to control inbound and outbound traffic rules, limit direct access between different systems, reduce potential attack surfaces, and ensure that a security incident in one VPC does not easily spread to others.
2. **Network Isolation and Clear Boundaries**: Independent VPCs create strict logical isolation between business units or projects at the network level, avoiding unnecessary interference. This is particularly important for large organizations, as it helps maintain clear responsibilities between departments and reduces the risk of accidental misoperations.
3. **Simplified Management and Maintenance**: For companies with multiple departments or projects, creating separate VPCs under each account simplifies network architecture. Administrators can customize network settings within each VPC without affecting others, making overall IT infrastructure management easier.
4. **Optimized Cost Control**: By leveraging the billing models of cloud service providers like AWS, businesses can track actual consumption across different departments or projects by deploying applications in separate VPCs, enabling more precise cost accounting and budget planning.
5. **Improved Flexibility and Multi-Environment Deployment**: Development teams can easily replicate the entire network structure to quickly build isolated runtime environments for testing, pre-production, and production, supporting agile development processes and accelerating product iteration cycles.
6. **Regulatory Compliance**: Certain industries may have strict requirements on data storage locations and transmission paths. Independent VPCs help meet these compliance needs by allowing deployments in specific geographic regions or availability zones to ensure adherence to local laws.

In summary, adopting an independent VPC approach not only enhances system security and stability but also provides greater operational flexibility and better resource management capabilities for businesses.
