# Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
    service_account_id = "${yandex_iam_service_account.tech-account.id}"
    description        = "static access key for bucket"
}

# Use keys to create bucket
resource "yandex_storage_bucket" "project-bucket" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = "k8s-tech"
    max_size = 1024
}