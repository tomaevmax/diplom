output "access_key" {
  value = yandex_iam_service_account_static_access_key.bucket-account-key.access_key
}
output "secret_key" {
  value = yandex_iam_service_account_static_access_key.bucket-account-key.secret_key
  sensitive = true
}
output "external_ip" {
 value = yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address
}
/*output "certificate_chain" {
  value = data.yandex_cm_certificate_content.ssl.certificates
}
output "certificate_key" {
  value = data.yandex_cm_certificate_content.ssl.private_key
  sensitive = true
}*/