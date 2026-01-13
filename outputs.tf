output "sta_id" {
  description = "The id of Storage Account deployed."
  value       = azurerm_storage_account.storage_account_service[0].id
}

output "sta_name" {
  description = "The name of Storage Account deployed."
  value       = azurerm_storage_account.storage_account_service[0].name
}

output "sta_blob_container_id" {
  description = "The id of Storage Blob Container deployed (If a container is not created this value will be null)."
  value = local.is_blob_type == true && var.create_container == true ? [
    for container in azurerm_storage_container.container : container.id
  ] : null
}
output "sta_blob_container_name" {
  description = "The name of Storage Blob Container deployed  (If a container is not created this value will be null)."
  value = local.is_blob_type == true && var.create_container == true ? [
    for container in azurerm_storage_container.container : container.name
  ] : null
}

output "sta_share_id" {
  description = "The id of Storage File Share deployed (If a File Share is not created this value will be null)."
  value       = local.is_files_type == true ? azurerm_storage_share.fileshare[0].id : null
}
output "sta_share_name" {
  description = "The name of Storage File Share deployed (If a File Share is not created this value will be null."
  value       = local.is_files_type == true ? azurerm_storage_share.fileshare[0].name : null
}

output "sta_primary_connection_string" {
  description = "The primary conection string of the Storage Account."
  value       = azurerm_storage_account.storage_account_service[0].primary_connection_string
  sensitive   = true
}

output "sta_identity_object_id" {
  description = "The Principal ID of the Storage Account Identity."
  value = azurerm_storage_account.storage_account_service[0].identity[0].principal_id
}