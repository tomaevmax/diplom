output "access_key" {
  value = yandex_iam_service_account_static_access_key.bucket-account-key.access_key
}
output "secret_key" {
  value = yandex_iam_service_account_static_access_key.bucket-account-key.secret_key
  sensitive = true
}