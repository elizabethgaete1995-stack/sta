
# Define variables for local scope
locals {
  #geo_region = lookup(local.regions, var.location)
  sta_name    = join("", [var.app_name, var.location, var.entity,var.environment, var.sequence_number])
  diagnostic_monitor_enabled = substr(var.rsg_name, 3, 1) == "p" || var.analytics_diagnostic_monitor_enabled ? true : false
  mds_lwk_enabled            = var.analytics_diagnostic_monitor_lwk_id != null || (var.lwk_name != null && local.rsg_lwk != null)
  mds_sta_enabled            = var.analytics_diagnostic_monitor_sta_id != null || (var.analytics_diagnostic_monitor_sta_name != null && var.analytics_diagnostic_monitor_sta_rsg != null)
  mds_aeh_enabled            = var.analytics_diagnostic_monitor_aeh_name != null && (var.eventhub_authorization_rule_id != null || (var.analytics_diagnostic_monitor_aeh_namespace != null && var.analytics_diagnostic_monitor_aeh_rsg != null))

  is_blob_type       = (var.account_kind != "FileStorage" && var.storage_type == "Blob") ? true : false
  is_files_type      = (var.account_kind == "FileStorage" && (var.account_tier == "Premium" || var.account_tier == "premium")) && (var.storage_type == "Files_SMB") ? true : false
  is_smb_type        = (var.account_kind == "FileStorage" && (var.account_tier == "Premium" || var.account_tier == "premium")) && (var.storage_type == "Files_SMB") ? true : false
  replication_object = (local.is_blob_type == true && var.is_origin == true && var.create_container == true && (var.account_kind == "BlockBlobStorage" || var.account_kind == "StorageV2")) ? true : false
  destination        = local.sta_destination_id != null ? substr(local.sta_name, 3, 1) == substr(split("/", local.sta_destination_id)[8], 3, 1) : false

  versioning = var.account_tier == "Premium" && var.account_replication_type == "LRS" ? false : true

  subscription       = var.subscription_id != null ? var.subscription_id : data.azurerm_client_config.current.subscription_id
  location           = var.location != null ? var.location : data.azurerm_resource_group.rsg_principal.location
  rsg_akv            = var.key_custom_enabled ? (var.akv_rsg_name != null ? var.akv_rsg_name : data.azurerm_resource_group.rsg_principal.name) : null
  rsg_lwk            = var.lwk_rsg_name != null ? var.lwk_rsg_name : data.azurerm_resource_group.rsg_principal.name
  akv_id             = var.key_custom_enabled ? (var.akv_id != null ? var.akv_id : "/subscriptions/${local.subscription}/resourceGroups/${local.rsg_akv}/providers/Microsoft.KeyVault/vaults/${var.akv_name}") : null
  sta_destination_id = var.destination_id != null ? var.destination_id : (var.subscription_id_destination != null && var.dest_rsg_name != null && var.dest_sta_name != null ? "/subscriptions/${var.subscription_id_destination}/resourceGroups/${var.dest_rsg_name}/providers/Microsoft.Storage/storageAccounts/${var.dest_sta_name}" : null)
}

##DATAS

# Get info about curent session
data "azurerm_client_config" "current" {}

# Get and set a resource group for deploy. 
data "azurerm_resource_group" "rsg_principal" {
  name = var.rsg_name
}


data "azurerm_key_vault_key" "key_principal" {
  count      = var.key_custom_enabled ? 1 : 0
  depends_on = [azurerm_key_vault_key.generated]

  name         = var.key_name == null ? local.sta_name : var.key_name
  key_vault_id = local.akv_id
}


# Get and set a monitor diagnostic settings
data "azurerm_log_analytics_workspace" "lwk_principal" {
  count = local.mds_lwk_enabled && var.analytics_diagnostic_monitor_lwk_id == null ? 1 : 0

  name                = var.lwk_name
  resource_group_name = local.rsg_lwk
}

# Get and set a Storage Account to send logs in monitor diagnostic settings
data "azurerm_storage_account" "mds_sta" {
  count = local.mds_sta_enabled && var.analytics_diagnostic_monitor_sta_id == null ? 1 : 0

  name                = var.analytics_diagnostic_monitor_sta_name
  resource_group_name = var.analytics_diagnostic_monitor_sta_rsg
}

# Get and set a Event Hub Authorization Rule to send logs in monitor diagnostic settings
data "azurerm_eventhub_namespace_authorization_rule" "mds_aeh" {
  count = local.mds_aeh_enabled && var.eventhub_authorization_rule_id == null ? 1 : 0

  name                = var.analytics_diagnostic_monitor_aeh_policy
  resource_group_name = var.analytics_diagnostic_monitor_aeh_rsg
  namespace_name      = var.analytics_diagnostic_monitor_aeh_namespace
}


# Get Storage Account dgm categories 
data "azurerm_monitor_diagnostic_categories" "sta" {
  resource_id = resource.azurerm_storage_account.storage_account_service[0].id
}

# Get Blob Storage Account dgm categories
data "azurerm_monitor_diagnostic_categories" "blob" {
  count       = local.is_blob_type ? 1 : 0
  resource_id = "${resource.azurerm_storage_account.storage_account_service[0].id}/blobServices/default"
}

# Get Files Storage Account dgm categories
data "azurerm_monitor_diagnostic_categories" "file" {
  count       = local.is_files_type ? 1 : 0
  resource_id = "${resource.azurerm_storage_account.storage_account_service[0].id}/fileServices/default"
}

## RESOURCES

# Create and configure a Key
resource "azurerm_key_vault_key" "generated" {
  count = !var.key_exist && var.key_custom_enabled ? 1 : 0

  name         = var.key_name == null ? local.sta_name : var.key_name
  key_vault_id = local.akv_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  expiration_date =  var.expiration_date_key
  
  rotation_policy {
    expire_after = var.expire_after
    notify_before_expiry = var.notify_before_expiry
    automatic {
      time_after_creation = var.time_after_creation
    }  
  }

  tags = var.inherit ? (length(module.tags.tags) < 16 ? module.tags.tags : module.tags.mandatory_tags) : (length(module.tags.tags_complete) < 16 ? module.tags.tags_complete : module.tags.mandatory_tags)
}

# Create and configure a azurerm storage account
resource "azurerm_storage_account" "storage_account_service" {
  count = local.is_blob_type || local.is_files_type ? 1 : 0

  name                = local.sta_name
  resource_group_name = var.rsg_name
  location            = local.location
  account_kind        = var.account_kind
  account_tier        = var.account_tier
  #WA for issue in re-apply with var.access_tier == "Hot" when var.account_kind == "BlockBlobStorage", if set both variables, it will be a re-apply producee a change in place re-apply. If it if you set null with , don't produce a re-apply
  access_tier                     = var.account_kind == "BlockBlobStorage" && var.access_tier == "Hot" ? null : var.access_tier
  account_replication_type        = var.account_replication_type
  enable_https_traffic_only       = true
  is_hns_enabled                  = var.is_hns_enabled
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = local.is_files_type ? null : var.shared_access_key_enabled
  allow_nested_items_to_be_public = false
  public_network_access_enabled    = var.public_network_access_enabled
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled

  identity {
    type = "SystemAssigned"
  }

  dynamic "static_website" {
    for_each = var.static_website == true && (var.account_kind == "BlockBlobStorage" || var.account_kind == "StorageV2") && !(var.index_document == null && var.error_404_document == null) ? [1] : []
    content {
      index_document = var.index_document
      error_404_document = var.error_404_document
    }
  }

  dynamic "blob_properties" {
    for_each = local.is_blob_type ? [1] : []
    content {
      delete_retention_policy {
        days = var.delete_retention_days
      }
      versioning_enabled       = var.versioning_enabled != null ? var.versioning_enabled : ((local.versioning && !var.is_hns_enabled && (local.replication_object || !var.is_origin)) ? true : false)
      last_access_time_enabled = var.last_access_time_enabled
      change_feed_enabled      = var.change_feed_enabled != null ? var.change_feed_enabled : (local.replication_object == true ? true : false)
      container_delete_retention_policy {
        days = var.delete_retention_days
      }
    }
  }

  dynamic "share_properties" {
    for_each = local.is_files_type ? [1] : []
    content {
      retention_policy {
        days = var.delete_retention_days
      }
      dynamic "smb" {
        for_each = local.is_smb_type ? [1] : []
        content {
          versions = ["SMB3.1.1"]
        }
      }
    }
  }

  network_rules {
    default_action             = var.waiver_sp54_STA_NoNetworksACLDefault_value
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
    bypass                     = var.bypass
    ip_rules                   = distinct(compact(concat(var.ip_rules, module.whitelist.ip_whitelist)))

    dynamic "private_link_access" {
      for_each = toset(var.endpoint_resource_ids)
      content {
        endpoint_resource_id = private_link_access.key
        endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
      }
    }
  }

  tags = var.inherit ? module.tags.tags : module.tags.tags_complete

  lifecycle {
    ignore_changes = [
      customer_managed_key,
      allow_nested_items_to_be_public
    ]
  }
}

resource "azurerm_storage_management_policy" "storage_policy" {
  count      = length(var.storage_policy_rules) > 0 && local.is_blob_type ? 1 : 0
  depends_on = [azurerm_storage_account.storage_account_service, azurerm_storage_container.container]

  storage_account_id = azurerm_storage_account.storage_account_service[0].id

  dynamic "rule" {
    for_each = { for k, v in var.storage_policy_rules : v.name => v }
    content {
      name    = rule.key
      enabled = rule.value.enabled
      filters {
        blob_types   = rule.value.filters.blob_types
        prefix_match = try(rule.value.filters.prefix_match, [])
        dynamic "match_blob_index_tag" {
          for_each = try(rule.value.filters.match_blob_index_tag, [])
          content {
            name      = match_blob_index_tag.value.name
            operation = try(match_blob_index_tag.value.operation, "==")
            value     = match_blob_index_tag.value.value
          }
        }
      }

      actions {
        dynamic "base_blob" {
          for_each = (rule.value.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than == null && rule.value.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than == null && rule.value.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than == null && rule.value.actions.base_blob.auto_tier_to_hot_from_cool_enabled == null && rule.value.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than == null && rule.value.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than == null && rule.value.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than == null && rule.value.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than == null && rule.value.actions.base_blob.delete_after_days_since_modification_greater_than == null && rule.value.actions.base_blob.delete_after_days_since_modification_greater_than == null && rule.value.actions.base_blob.delete_after_days_since_creation_greater_than == null) ? [] : [1]
          content {
            tier_to_cool_after_days_since_modification_greater_than        = try(rule.value.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than, null)
            tier_to_cool_after_days_since_last_access_time_greater_than    = try(rule.value.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than, null)
            tier_to_cool_after_days_since_creation_greater_than            = try(rule.value.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than, null)
            auto_tier_to_hot_from_cool_enabled                             = try(rule.value.actions.base_blob.auto_tier_to_hot_from_cool_enabled, null)
            tier_to_archive_after_days_since_modification_greater_than     = try(rule.value.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than, null)
            tier_to_archive_after_days_since_last_access_time_greater_than = try(rule.value.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than, null)
            tier_to_archive_after_days_since_creation_greater_than         = try(rule.value.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than, null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = try(rule.value.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than, null)
            delete_after_days_since_modification_greater_than              = try(rule.value.actions.base_blob.delete_after_days_since_modification_greater_than, null)
            delete_after_days_since_last_access_time_greater_than          = try(rule.value.actions.base_blob.delete_after_days_since_last_access_time_greater_than, null)
            delete_after_days_since_creation_greater_than                  = try(rule.value.actions.base_blob.delete_after_days_since_creation_greater_than, null)
          }
        }
        dynamic "snapshot" {
          for_each = (rule.value.actions.snapshot.change_tier_to_archive_after_days_since_creation == null && rule.value.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than == null && rule.value.actions.snapshot.change_tier_to_cool_after_days_since_creation == null && rule.value.actions.snapshot.delete_after_days_since_creation_greater_than == null) ? [] : [1]
          content {
            change_tier_to_archive_after_days_since_creation               = try(rule.value.actions.snapshot.change_tier_to_archive_after_days_since_creation, null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = try(rule.value.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than, null)
            change_tier_to_cool_after_days_since_creation                  = try(rule.value.actions.snapshot.change_tier_to_cool_after_days_since_creation, null)
            delete_after_days_since_creation_greater_than                  = try(rule.value.actions.snapshot.delete_after_days_since_creation_greater_than, null)
          }
        }
        dynamic "version" {
          for_each = (rule.value.actions.version.change_tier_to_archive_after_days_since_creation == null && rule.value.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than == null && rule.value.actions.version.change_tier_to_cool_after_days_since_creation == null && rule.value.actions.version.delete_after_days_since_creation == null) ? [] : [1]
          content {
            change_tier_to_archive_after_days_since_creation               = try(rule.value.actions.version.change_tier_to_archive_after_days_since_creation, null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = try(rule.value.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than, null)
            change_tier_to_cool_after_days_since_creation                  = try(rule.value.actions.version.change_tier_to_cool_after_days_since_creation, null)
            delete_after_days_since_creation                               = try(rule.value.actions.version.delete_after_days_since_creation, null)
          }
        }
      }
    }
  }
}

resource "azurerm_storage_container" "container" {
  for_each = local.is_blob_type && var.create_container ? (var.container_name != null ? toset(var.container_name) : [1]) : []

  name                  = var.container_name == null ? "${azurerm_storage_account.storage_account_service[0].name}-cont" : each.key
  storage_account_name  = azurerm_storage_account.storage_account_service[0].name
  container_access_type = "private"
}

resource "azurerm_storage_object_replication" "replication" {
  count = local.destination && var.create_container && var.account_tier != "Premium" ? 1 : 0

  source_storage_account_id      = azurerm_storage_account.storage_account_service[0].id
  destination_storage_account_id = local.sta_destination_id
  dynamic "rules" {
    for_each = var.rules
    content {
      source_container_name      = rules.value["orig_container_name"]
      destination_container_name = rules.value["dest_container_name"]
    }
  }
}

# Create File Share folder. Supported only in the combinations StorageV2+Standard and FileStorage+Premium
resource "azurerm_storage_share" "fileshare" {
  count = local.is_files_type == true ? 1 : 0

  name                 = var.share_name == null ? local.sta_name : var.share_name
  storage_account_name = azurerm_storage_account.storage_account_service[0].name
  quota                = var.quota
}

# Create and configure a azurerm access policy
resource "azurerm_key_vault_access_policy" "kvt_access_policy" {
  count = var.key_custom_enabled && !var.enable_rbac_authorization ? 1 : 0

  key_vault_id = local.akv_id
  tenant_id    = azurerm_storage_account.storage_account_service[0].identity.0.tenant_id
  object_id    = azurerm_storage_account.storage_account_service[0].identity.0.principal_id
  key_permissions = [
    "Encrypt",
    "Decrypt",
    "WrapKey",
    "UnwrapKey",
    "Sign",
    "Verify",
    "Get",
    "List",
    "Create",
    "Update",
    "Import",
    "Delete",
    "Backup",
    "Restore",
    "Recover",
    "Purge",
    "SetRotationPolicy",
    "GetRotationPolicy",
    "Rotate"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Backup",
    "Restore",
    "Recover",
    "Purge"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Delete",
    "Create",
    "Import",
    "Update",
    "ManageContacts",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers",
    "ManageIssuers",
    "Recover",
    "Purge",
    "Backup",
    "Restore"
  ]

  storage_permissions = [
    "Get",
    "List",
    "Delete",
    "Set",
    "Update",
    "RegenerateKey",
    "Recover",
    "Purge",
    "Backup",
    "Restore",
    "SetSAS",
    "ListSAS",
    "GetSAS",
    "DeleteSAS"
  ]
}

resource "azurerm_role_assignment" "kv_role_assignment" {
  count                = var.key_custom_enabled && var.enable_rbac_authorization ? 1 : 0
  
  scope                = local.akv_id
  role_definition_name = "Santander Key Vault Administrator"
  principal_id         = azurerm_storage_account.storage_account_service[0].identity.0.principal_id
}

# Create and configure a azurerm customer managed key
resource "azurerm_storage_account_customer_managed_key" "cmk" {
  count      = var.key_custom_enabled ? 1 : 0
  depends_on = [azurerm_key_vault_access_policy.kvt_access_policy, azurerm_role_assignment.kv_role_assignment]

  storage_account_id = azurerm_storage_account.storage_account_service[0].id
  key_vault_id       = local.akv_id
  key_name           = var.key_name == "" ? local.sta_name : var.key_name
  key_version        = var.key_rotation ? null : data.azurerm_key_vault_key.key_principal[0].version
}

resource "azurerm_advanced_threat_protection" "threat_protection" {
  depends_on = [azurerm_storage_account.storage_account_service]

  target_resource_id = azurerm_storage_account.storage_account_service[0].id
  enabled            = var.threat_protection_enabled
  

  lifecycle {
    ignore_changes = [enabled, ]
  }
}

# Create and configure a azurerm monitor diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "sta" {
  count = local.diagnostic_monitor_enabled ? 1 : 0

  name                           = var.analytics_diagnostic_monitor_name
  target_resource_id             = azurerm_storage_account.storage_account_service[0].id
  log_analytics_workspace_id     = local.mds_lwk_enabled ? (var.analytics_diagnostic_monitor_lwk_id != null ? var.analytics_diagnostic_monitor_lwk_id : data.azurerm_log_analytics_workspace.lwk_principal[0].id) : null
  eventhub_name                  = local.mds_aeh_enabled ? var.analytics_diagnostic_monitor_aeh_name : null
  eventhub_authorization_rule_id = local.mds_aeh_enabled ? (var.eventhub_authorization_rule_id != null ? var.eventhub_authorization_rule_id : data.azurerm_eventhub_namespace_authorization_rule.mds_aeh[0].id) : null
  storage_account_id             = local.mds_sta_enabled ? (var.analytics_diagnostic_monitor_sta_id != null ? var.analytics_diagnostic_monitor_sta_id : data.azurerm_storage_account.mds_sta[0].id) : null

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.sta.log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.sta.metrics
    content {
      category = metric.value
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  count = local.diagnostic_monitor_enabled && local.is_blob_type ? 1 : 0

  name                           = var.analytics_diagnostic_monitor_name
  target_resource_id             = "${azurerm_storage_account.storage_account_service[0].id}/blobServices/default"
  log_analytics_workspace_id     = local.mds_lwk_enabled ? (var.analytics_diagnostic_monitor_lwk_id != null ? var.analytics_diagnostic_monitor_lwk_id : data.azurerm_log_analytics_workspace.lwk_principal[0].id) : null
  eventhub_name                  = local.mds_aeh_enabled ? var.analytics_diagnostic_monitor_aeh_name : null
  eventhub_authorization_rule_id = local.mds_aeh_enabled ? (var.eventhub_authorization_rule_id != null ? var.eventhub_authorization_rule_id : data.azurerm_eventhub_namespace_authorization_rule.mds_aeh[0].id) : null
  storage_account_id             = local.mds_sta_enabled ? (var.analytics_diagnostic_monitor_sta_id != null ? var.analytics_diagnostic_monitor_sta_id : data.azurerm_storage_account.mds_sta[0].id) : null

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.blob[0].log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.blob[0].metrics
    content {
      category = metric.value
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "file" {
  count = local.diagnostic_monitor_enabled && local.is_files_type ? 1 : 0

  name                           = var.analytics_diagnostic_monitor_name
  target_resource_id             = "${azurerm_storage_account.storage_account_service[0].id}/fileServices/default"
  log_analytics_workspace_id     = local.mds_lwk_enabled ? (var.analytics_diagnostic_monitor_lwk_id != null ? var.analytics_diagnostic_monitor_lwk_id : data.azurerm_log_analytics_workspace.lwk_principal[0].id) : null
  eventhub_name                  = local.mds_aeh_enabled ? var.analytics_diagnostic_monitor_aeh_name : null
  eventhub_authorization_rule_id = local.mds_aeh_enabled ? (var.eventhub_authorization_rule_id != null ? var.eventhub_authorization_rule_id : data.azurerm_eventhub_namespace_authorization_rule.mds_aeh[0].id) : null
  storage_account_id             = local.mds_sta_enabled ? (var.analytics_diagnostic_monitor_sta_id != null ? var.analytics_diagnostic_monitor_sta_id : data.azurerm_storage_account.mds_sta[0].id) : null

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.file[0].log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.file[0].metrics
    content {
      category = metric.value
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
