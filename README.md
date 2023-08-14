# Terraform Configuration for GCP Load Balancer with Cloud Functions
This Terraform configuration sets up an HTTPS Load Balancer in Google Cloud Platform (GCP) that routes traffic to specified Google Cloud Functions.

## Benefits of Centralized Management
Centralizing your Cloud Functions under a singular domain with an HTTPS Load Balancer offers several advantages:

1. By having a unified entry point, it simplifies the configuration, making it easier to add, modify, or remove Cloud Functions in the future.
2. With a centralized approach, you can apply consistent security policies across all Cloud Functions, enhancing the overall security posture.
4. Monitoring and logging can be consolidated, providing a holistic view of how traffic interacts with your Cloud Functions.
<hr>

- [Requirements](#requirements)
- [Overview](#overview)
- [Cloud Function to Domain Mapping](#cloud-function-to-domain-mapping)
- [Configuration](#configuration)
- [Testing](#testing)

## Requirements
Before setting up the Terraform configuration, ensure you have the following prerequisites in place:

- **Reserved IP Address**: The configuration assumes that you have a reserved static IP address available in your Google Cloud Project. This IP address will be associated with the HTTPS Load Balancer.
- **SSL Certificate**: You should have a valid SSL certificate available in your Google Cloud Project.
- **A Record Setup**: Make sure to create an A DNS record that points your desired domain (e.g., sample.cclab.cloud-castles.com) to the reserved static IP address from the first requirement.
- **Existing Cloud-Functions**: To be used as a backend service.

## Overview
1. **Google Cloud Functions**: Cloud functions which will be attached to the HTTPS load balancer.
2. **Backend Service and Network Endpoint Groups (NEG)**: For every Cloud Function specified, a corresponding Serverless NEG is created which refers to the Cloud Function. This NEG is then used as a backend in the Backend Service.
3. **HTTPS Load Balancer**: The main Load Balancer configuration which uses the created backend services to route traffic based on paths to specific Cloud Functions.

## Cloud Function to Domain Mapping
The Terraform configuration uses a variable named domain to determine the primary domain for the HTTPS Load Balancer. Each Cloud Function specified in the configuration will then be mapped as a subpath under this primary domain.

For example, if:

```
domain = "sample.cclab.cloud-castles.com"
```
The Cloud Function named function-1 will be accessible via the URL:

```
https://sample.cclab.cloud-castles.com/function-1
```
Similarly, a Cloud Function named function-2 will be accessible at:

```
https://sample.cclab.cloud-castles.com/function-2
```
And so on, for all the Cloud Functions you specify. This mapping ensures that each Cloud Function has a dedicated and predictable endpoint under the primary domain, making it easy to route traffic and organize services.

## Testing
The following syntax may be used to test your load balancer:
```
curl -m 70 -X POST https://sample.cclab.cloud-castles.com/function-1 \
-H "Authorization: bearer $(gcloud auth print-identity-token)" \
-H "Content-Type: application/json" \
-d '{}'
```

## Configuration
- name_prefix: Naming prefix for your GCP resources.
- gcp_project: The GCP project ID.
- gcp_region: The GCP region where the resources are provisioned.
- static_ip_resource_name: Name of the reserved IP address resource.
- certificate_name: Existing SSL certificate name.
- function_list: List of Cloud Functions to be attached to the load balancer.
- domain: The domain name for your load balancer. (Should match the SSL certificate)

You may use this sample for your convenience
```
name_prefix              = "staging"
gcp_project              = "cc-s2s-vpn-test"
certificate_name         = "sample-cert"
static_ip_resource_name  = "sample-ip"
gcp_region               = "us-central1"
function_list            = ["function-1", "function-2"]
domain                   = "sample.cclab.cloud-castles.com"
```
