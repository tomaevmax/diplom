resource "yandex_dns_zone" "diplom" {
  name        = "diplom"
  description = "домен на время диплома"
  zone             = "tomaev-maksim.ru."
  public           = true
}

resource "yandex_cm_certificate" "ssl" {
  name    = "ssl"
  domains = ["tomaev-maksim.ru", "*.tomaev-maksim.ru"]

  managed {
    challenge_type  = "DNS_CNAME"
    challenge_count = 1 # "example.com" and "*.example.com" has the same DNS_CNAME challenge
  }
  depends_on = [
    yandex_dns_zone.diplom
  ]
}

resource "yandex_dns_recordset" "verify" {
  count   = yandex_cm_certificate.ssl.managed[0].challenge_count
  zone_id = yandex_dns_zone.diplom.id
  name    = yandex_cm_certificate.ssl.challenges[count.index].dns_name
  type    = yandex_cm_certificate.ssl.challenges[count.index].dns_type
  data    = [yandex_cm_certificate.ssl.challenges[count.index].dns_value]
  ttl     = 60
  depends_on = [
    yandex_cm_certificate.ssl
  ]
}
