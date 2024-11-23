provider "cloudflare" {
  api_token = var.cloudflare_api_key
}

data "cloudflare_zone" "cf_zone" {
  name = var.domain
}

resource "cloudflare_record" "record" {
  for_each = toset(var.records)

  zone_id         = data.cloudflare_zone.cf_zone.id
  name            = "${each.value}.${var.prefix}.${var.domain}"
  value           = var.ip
  type            = "A"
  ttl             = 60
  allow_overwrite = true
}
