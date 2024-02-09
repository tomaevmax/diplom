# Use keys to create bucket
resource "yandex_iam_service_account" "bucket-account" {
  name        = "bucket-account"
  description = "bucket service account"
}

resource "yandex_resourcemanager_folder_iam_member" "bucket-account" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-account.id}"
}

# Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "bucket-account-key" {
    service_account_id = yandex_iam_service_account.bucket-account.id
    description        = "static access key for bucket"
}

resource "yandex_storage_bucket" "project-bucket" {
    access_key = yandex_iam_service_account_static_access_key.bucket-account-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.bucket-account-key.secret_key
    bucket = "k8s-tech"
    depends_on = [
    yandex_iam_service_account.bucket-account,yandex_resourcemanager_folder_iam_member.bucket-account,yandex_iam_service_account_static_access_key.bucket-account-key]
}

# Add picture to bucket
resource "yandex_storage_object" "object-1" {
    access_key = yandex_iam_service_account_static_access_key.bucket-account-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.bucket-account-key.secret_key
    bucket = yandex_storage_bucket.project-bucket.bucket
    key = "logo.png"
    source = "inventory/logo.png"
    acl    = "public-read"
    depends_on = [yandex_storage_bucket.project-bucket]
}