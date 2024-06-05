## Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-storage-admin-static-key" {
  service_account_id = data.yandex_iam_service_account.sa-storage-admin.id
  description        = "static access key for object storage"
}

resource "yandex_iam_service_account_static_access_key" "sa-key" {
  service_account_id = data.yandex_iam_service_account.sa-key.id
  description        = "static access key for manipulation"
}

## Use keys to create bucket
resource "yandex_storage_bucket" "terrafrom-state" {
  access_key = yandex_iam_service_account_static_access_key.sa-storage-admin-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-storage-admin-static-key.secret_key
  bucket     = "terrafrom-state-file"
}

output "access_key_sa_storage_admin_for_terrafrom-state-bucket" {
  description = "access_key sa-storage-admin for terrafrom-state"
  value       = yandex_storage_bucket.terrafrom-state.access_key
  sensitive   = true
}

output "secret_key_sa_storage_admin_for_terrafrom-state-bucket" {
  description = "secret_key sa-storage-admin for terrafrom-state"
  value       = yandex_storage_bucket.terrafrom-state.secret_key
  sensitive   = true
}
