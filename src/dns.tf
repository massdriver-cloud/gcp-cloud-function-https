locals {
  domain           = "${var.subdomain}.${data.google_dns_managed_zone.main.dns_name}"
  full_url         = "https://${local.domain}"
  zone_has_slashes = length(split("/", var.cloud_dns_managed_zone.name)) > 1
  dns_zone_name    = local.zone_has_slashes ? split("/", var.cloud_dns_managed_zone.name)[3] : var.cloud_dns_managed_zone.name
}

data "google_dns_managed_zone" "main" {
  name = local.dns_zone_name
  depends_on = [
    module.apis
  ]
}

resource "google_dns_record_set" "set" {
  name         = local.domain
  type         = "A"
  ttl          = 3600
  managed_zone = data.google_dns_managed_zone.main.name
  rrdatas      = [google_compute_global_forwarding_rule.main.ip_address]
}
