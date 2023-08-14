variable "gcp_project" {
  description = "GCP Project"
  type        = string
  default     = "us-central1"
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix for GCP resources"
  type        = string
}

variable "static_ip_resource_name" {
  description = "Name issued to your reserved IP address resource - Will be attached to the Loadbalancer"
  type        = string
}

variable "certificate_name" {
  description = "Your existing certificate name"
  type        = string
}

variable "function_list" {
  description = "A map of functions to attach to the load balancer"
  type        = list(string)
}

variable "domain" {
  description = "Your loadbalancer domain name"
  type        = string
}