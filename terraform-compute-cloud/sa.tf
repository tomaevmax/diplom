resource "yandex_iam_service_account" "tech-account" {
  name        = "tech-account"
  description = "K8S regional service account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-editor" {
  # Сервисному аккаунту назначается роль "k8s.editor".
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.tech-account.id}"
}