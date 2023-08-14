locals {
  # Translates the list of functions (strings) into a map of strings to allow iteration.
  function_map = { for function in var.function_list : function => function }

  # Extracts first string from domain - Used as a path_matcher for load balancer.
  path_matcher = element(split(".", var.domain), 0)
}

data "google_compute_global_address" "reserved_address" {
  name = var.static_ip_resource_name
}

data "google_compute_ssl_certificate" "ssl" {
  name = var.certificate_name
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each              = local.function_map
  name                  = "${var.name_prefix}-${each.key}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.gcp_region
  cloud_function {
    function = "${each.key}"
  }
}

resource "google_compute_backend_service" "serverless_service" {
  for_each         = local.function_map
  name             = "${var.name_prefix}-${each.key}-backend-service"
  protocol         = "HTTPS"
  port_name        = "http"
  enable_cdn       = false
  security_policy  = null
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg[each.key].self_link
  }
}

resource "google_compute_url_map" "lb" {
  name            = "${var.name_prefix}-serverless-lb"
  default_service = google_compute_backend_service.serverless_service[keys(local.function_map)[0]].self_link

  host_rule {
    hosts        = [var.domain]
    path_matcher = local.path_matcher
  }

  path_matcher {
    name = local.path_matcher

    default_service = google_compute_backend_service.serverless_service[keys(local.function_map)[0]].self_link

    dynamic "path_rule" {
      for_each = local.function_map
      content {
        paths   = ["/${path_rule.key}"]
        service = google_compute_backend_service.serverless_service[path_rule.key].self_link
      }
    }
  }
}

resource "google_compute_target_https_proxy" "proxy" {
  name             = "${var.name_prefix}-https-proxy"
  url_map          = google_compute_url_map.lb.self_link
  ssl_certificates = [data.google_compute_ssl_certificate.ssl.self_link]
}

resource "google_compute_global_forwarding_rule" "forwarding" {
  name       = "${var.name_prefix}-https-lb-rule"
  target     = google_compute_target_https_proxy.proxy.self_link
  port_range = "443"
  ip_address = data.google_compute_global_address.reserved_address.address
}