locals {
  domain   = "${var.subdomain}.${data.google_dns_managed_zone.main.dns_name}"
  full_url = "https://${local.domain}"

  zone      = var.cloud_dns_managed_zone.name
  zone_name = length(split("/", local.zone)) > 1 ? split("/", local.zone)[3] : local.zone
}

data "google_dns_managed_zone" "main" {
  name = local.zone_name
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
