data "yandex_iam_service_account" "sa-storage-admin" {
  folder_id = var.yc_folder_id
  name      = "sa-storage-admin"
}

data "yandex_iam_service_account" "sa-key" {
  folder_id = var.yc_folder_id
  name      = "sa-key"
}


resource "yandex_iam_service_account" "k-admin" {
  name = "k-admin"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.k-admin.id}"
  ]
  depends_on = [
    yandex_iam_service_account.k-admin,
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-clusters-agent" {
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.k-admin.id}"
  ]
  depends_on = [
    yandex_iam_service_account.k-admin,
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {
  folder_id = var.yc_folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.k-admin.id}"
  ]
  depends_on = [
    yandex_iam_service_account.k-admin,
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.k-admin.id}"
  ]
  depends_on = [
    yandex_iam_service_account.k-admin,
  ]
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
  symmetric_key_id = yandex_kms_symmetric_key.kms-key.id
  role             = "viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.k-admin.id}",
  ]
  depends_on = [
    yandex_iam_service_account.k-admin,
  ]
}

resource "yandex_iam_service_account_static_access_key" "static-access-key" {
  service_account_id = yandex_iam_service_account.k-admin.id
  depends_on = [
    yandex_iam_service_account.k-admin,
  ]
}

