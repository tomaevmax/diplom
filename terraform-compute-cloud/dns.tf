resource "yandex_dns_zone" "diplom" {
  name        = "diplom"
  description = "домен на время диплома"
  zone             = "tomaev-maksim.ru."
  public           = true
}
resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.diplom.id
  name    = "grafana.tomaev-maksim.ru."
  type    = "A"
  ttl     = 200
  data    = ["${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address}"]
  depends_on = [
    yandex_compute_instance_group.k8s-node
  ]
}
resource "yandex_dns_recordset" "test-app" {
  zone_id = yandex_dns_zone.diplom.id
  name    = "test-app.tomaev-maksim.ru."
  type    = "A"
  ttl     = 200
  data    = ["${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address}"]
  depends_on = [
    yandex_compute_instance_group.k8s-node
  ]
}
resource "yandex_dns_recordset" "gitlab" {
  zone_id = yandex_dns_zone.diplom.id
  name    = "gitlab.tomaev-maksim.ru."
  type    = "A"
  ttl     = 200
  data    = ["${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address}"]
  depends_on = [
    yandex_compute_instance_group.k8s-node
  ]
}
resource "yandex_dns_recordset" "minio" {
  zone_id = yandex_dns_zone.diplom.id
  name    = "minio.tomaev-maksim.ru."
  type    = "A"
  ttl     = 200
  data    = ["${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address}"]
  depends_on = [
    yandex_compute_instance_group.k8s-node
  ]
}
resource "yandex_dns_recordset" "registry" {
  zone_id = yandex_dns_zone.diplom.id
  name    = "registry.tomaev-maksim.ru."
  type    = "A"
  ttl     = 200
  data    = ["${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address}"]
  depends_on = [
    yandex_compute_instance_group.k8s-node
  ]
}
resource "yandex_dns_recordset" "kas" {
  zone_id = yandex_dns_zone.diplom.id
  name    = "kas.tomaev-maksim.ru."
  type    = "A"
  ttl     = 200
  data    = ["${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address}"]
  depends_on = [
    yandex_compute_instance_group.k8s-node
  ]
}
/*resource "yandex_cm_certificate" "ssl" {
  name    = "ssl"
  domains = ["tomaev-maksim.ru", "*.tomaev-maksim.ru"] #  "tomaev-maksim.ru", "*.tomaev-maksim.ru"

  managed {
    challenge_type  = "DNS_CNAME"
    challenge_count = 1 # "example.com" and "*.example.com" has the same DNS_CNAME challenge
  }
}

resource "yandex_dns_recordset" "verify" {
  count   = yandex_cm_certificate.ssl.managed[0].challenge_count
  zone_id = yandex_dns_zone.diplom.id
  name    = yandex_cm_certificate.ssl.challenges[count.index].dns_name
  type    = yandex_cm_certificate.ssl.challenges[count.index].dns_type
  data    = [yandex_cm_certificate.ssl.challenges[count.index].dns_value]
  ttl     = 60
}

data "yandex_cm_certificate_content" "ssl" {
  certificate_id = yandex_cm_certificate.ssl.id
  wait_validation = true
}*/