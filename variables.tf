// COMMON VARIABLES

variable "subscription_id" {
  type        = string
  description = "(Required) The id of the subscription in which the resource is created. Changing this forces a new resource to be created."
}

variable "rsg_name" {
  type        = string
  description = "(Required) The name of the resource group in which the resource is created. Changing this forces a new resource to be created."
}
variable "location" {
  description = "Región Azure"
  type        = string
}

// PRODUCT
variable "storage_type" {
  type        = string
  description = "(Optional) Specifies the storage type that is required. Valid options are Blob and Files_SMB. Defaults to Blob. The Blob option can only be set when the account_kind is set not equal to FileStorage. The Files_SMB option can only be set when the account_kind and account_type are set to FileStorage and Premium."
  default     = "Blob"
}

variable "account_kind" {
  type        = string
  description = "(Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to StorageV2"
  default     = "StorageV2"
}

variable "account_tier" {
  type        = string
  description = "(Required) Storage account access kind [ Standard | Premium ]."
}

variable "access_tier" {
  type        = string
  description = "(Optional) Storage account access tier for BlobStorage accounts [ Hot | Cool ]."
  default     = "Hot"
}

variable "threat_protection_enabled" {
  type        = bool
  description = "(Optional) Allows to enable (true) or disable (false) the threat protection resource. Defaults to false."
  default     = false
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to false."
  default     = false
}

variable "endpoint_resource_ids" {
  type        = list(string)
  description = "(Optional) A list of the ID of the Azure resources that should be allowed access to the target storage account."
  default     = []
}

variable "last_access_time_enabled" {
  type        = bool
  description = "(Optional) Is the last access time based tracking enabled? Default to false."
  default     = false
}

variable "storage_policy_rules" {
  type = list(object({
    name    = string
    enabled = bool
    filters = object({
      blob_types   = list(string)
      prefix_match = optional(list(string), [])
      match_blob_index_tag = optional(list(object({
        name      = string
        operation = optional(string, "==")
        value     = string
      })), [])
    })
    actions = object({
      base_blob = optional(object({
        tier_to_cool_after_days_since_modification_greater_than        = optional(number, null)
        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number, null)
        tier_to_cool_after_days_since_creation_greater_than            = optional(number, null)
        auto_tier_to_hot_from_cool_enabled                             = optional(bool, null)
        tier_to_archive_after_days_since_modification_greater_than     = optional(number, null)
        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number, null)
        tier_to_archive_after_days_since_creation_greater_than         = optional(number, null)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null)
        delete_after_days_since_modification_greater_than              = optional(number, null)
        delete_after_days_since_last_access_time_greater_than          = optional(number, null)
        delete_after_days_since_creation_greater_than                  = optional(number, null)
      }), {})
      snapshot = optional(object({
        change_tier_to_archive_after_days_since_creation               = optional(number, null)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null)
        change_tier_to_cool_after_days_since_creation                  = optional(number, null)
        delete_after_days_since_creation_greater_than                  = optional(number, null)
      }), {})
      version = optional(object({
        change_tier_to_archive_after_days_since_creation               = optional(number, null)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null)
        change_tier_to_cool_after_days_since_creation                  = optional(number, null)
        delete_after_days_since_creation                               = optional(number, null)
      }), {})
    })
  }))
  description = "(Optional) A rules list to set a policy to manage the Azure Storage Account. Consist of => name: (Required) The name of the rule. Rule name is case-sensitive. It must be unique within a policy; enabled: (Required) Boolean to specify whether the rule is enabled; filters: (Required) Filters to condition the actions to be performed in the rule. (Consists in => blob_types: (Required) An array of predefined values. Valid options are blockBlob and appendBlob; prefix_match: (Optional) An array of strings for prefixes to be matched; match_blob_index_tag: (Optional) A block that defines the blob index tag based filtering for blob objects. The match_blob_index_tag property requires enabling the blobIndex feature with [PSH or CLI commands](https://azure.microsoft.com/en-us/blog/manage-and-find-data-with-blob-index-for-azure-storage-now-in-preview/). (Consists in => name: (Required) The filter tag name used for tag based filtering for blob objects; operation: (Optional) The comparison operator which is used for object comparison and filtering. Possible value is ==. Defaults to ==; value: (Required) The filter tag value used for tag based filtering for blob objects.)); actions: (Required) Actions associated with the rule if filters are applied. (Consists in => base_blob: (Optional) (A block that supports the following => tier_to_cool_after_days_since_modification_greater_than: (Optional) The age in days after last modification to tier blobs to cool storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_cool_after_days_since_last_access_time_greater_than: (Optional) The age in days after last access time to tier blobs to cool storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_cool_after_days_since_creation_greater_than: (Optional) The age in days after creation to cool storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null. The tier_to_cool_after_days_since_modification_greater_than, tier_to_cool_after_days_since_last_access_time_greater_than and tier_to_cool_after_days_since_creation_greater_than can not be set at the same time; auto_tier_to_hot_from_cool_enabled: (Optional) Whether a blob should automatically be tiered from cool back to hot if it's accessed again after being tiered to cool. Defaults to false. The auto_tier_to_hot_from_cool_enabled must be used together with tier_to_cool_after_days_since_last_access_time_greater_than; tier_to_archive_after_days_since_modification_greater_than: (Optional) The age in days after last modification to tier blobs to archive storage. Supports blob currently at Hot or Cool tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_last_access_time_greater_than: (Optional) The age in days after last access time to tier blobs to archive storage. Supports blob currently at Hot or Cool tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_creation_greater_than: (Optional) The age in days after creation to archive storage. Supports blob currently at Hot or Cool tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null. The tier_to_archive_after_days_since_modification_greater_than, tier_to_archive_after_days_since_last_access_time_greater_than and tier_to_archive_after_days_since_creation_greater_than can not be set at the same time; tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) The age in days after last tier change to the blobs to skip to be archived. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; delete_after_days_since_modification_greater_than: (Optional) The age in days after last modification to delete the blob. Must be between 0 and 99999. Defaults to null; delete_after_days_since_last_access_time_greater_than: (Optional) The age in days after last access time to delete the blob. Must be between 0 and 99999. Defaults to null; delete_after_days_since_creation_greater_than: (Optional) The age in days after creation to delete the blob. Must be between 0 and 99999. Defaults to null. The delete_after_days_since_modification_greater_than, delete_after_days_since_last_access_time_greater_than and delete_after_days_since_creation_greater_than can not be set at the same time. The last_access_time_enabled must be set to true in order to use tier_to_cool_after_days_since_last_access_time_greater_than, tier_to_archive_after_days_since_last_access_time_greater_than and delete_after_days_since_last_access_time_greater_than.); snapshot: (Optional) (A block that supports the following => change_tier_to_archive_after_days_since_creation: (Optional) The age in days after creation to tier blob snapshot to archive storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) The age in days after last tier change to the blobs to skip to be archived. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; change_tier_to_cool_after_days_since_creation: (Optional) The age in days after creation to tier blob snapshot to cool storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; delete_after_days_since_creation_greater_than: (Optional) The age in days after creation to delete the blob snapshot. Must be between 0 and 99999. Defaults to null.); version: (Optional) (A block that supports the following => change_tier_to_archive_after_days_since_creation: (Optional) The age in days after creation to tier blob version to archive storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) The age in days after last tier change to the blobs to skip to be archved. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; change_tier_to_cool_after_days_since_creation: (Optional) The age in days creation create to tier blob version to cool storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; delete_after_days_since_creation:  (Optional) The age in days after creation to delete the blob version. Must be between 0 and 99999. Defaults to null.))."
  default     = []
}

variable "account_replication_type" {
  type        = string
  description = "(Optional) Storage account replication type [ LRS ZRS GRS RAGRS ]. ZRS is not supported with cool or archive tiers."
  default     = "ZRS"
}

variable "destination_id" {
  type        = string
  description = "(Optional) The resource id of the container storage account destination."
  default     = null
}

variable "is_hns_enabled" {
  type        = bool
  description = "(Optional) to allow Data Lake GEN 2, you need to set the variable account_kind to StorageV2. Changes this force a new resource."
  default     = false
}

variable "delete_retention_days" {
  type        = number
  description = "(Optional) Specifies the number of days that storage should be retained, between 1 and 365 days. Defaults to 7."
  default     = 7
}

variable "is_origin" {
  type        = bool
  description = "(Required) Is the storage acount the origin? Default to false."
  default     = false
}

variable "versioning_enabled" {
  type        = bool
  description = "(Optional) Is versioning enabled? Default to false. This feature is not available in Premium tier."
  default     = null
}

variable "change_feed_enabled" {
  type        = bool
  description = "Is the blob service properties for change feed events enabled? Default to false. This feature is not available in Premium tier."
  default     = null
}

variable "dest_sta_name" {

  type        = string
  description = "(Optional) The name of the destination Storage Account to replicate with. It must be of type Blob otherwise it will fail."
  default     = "xxxx"
}

variable "subscription_id_destination" {
  type        = string
  description = "(Required) The id of the subscription in which the destination resource is created. Changing this forces a new resource to be created."
  default     = null
}

variable "dest_rsg_name" {
  type        = string
  description = "(Optional) The name of the Resource Group where exist the destination Storage Account to replicate with."
  default     = null
}

variable "dest_container_name" {
  type        = string
  description = "(Optional) The name of the destination Blob Container to replicate with."
  default     = null
}

variable "quota" {
  type        = number
  description = "(Optional) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be 1GB (or higher) and at most 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and at most 102400 GB (100 TB)"
  default     = "5"
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  description = "(Optional) Should cross Tenant replication be enabled? Defaults to false."
  default     = false
}

variable "bypass" {
  type        = list(string)
  description = "(Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None."
  default     = ["AzureServices"]
}

variable "static_website" {
  type        = bool
  description = "(Optional) Allows to configure static website settings. The default value is false."
  default     = false
}

variable "index_document" {
  type        = string
  description = "(Optional) The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive. Only applies if static_website is true. Defaults to null."
  default     = null
}

variable "error_404_document" {
  type        = string
  description = "(Optional) The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file. Only applies if static_website is true. Defaults to null."
  default     = null
}

variable "rules" {
  type = list(object({
    orig_container_name = string
    dest_container_name = string
  }))
  description = "(Optional) The rules of replication that the Storage Account will have. A origin container can only have one destination container and a destination container can only have one origin container."
  default     = []
}

variable "ip_rules" {
  type        = list(any)
  description = "(Optional) The ranges of IPs to can access Storage Account."
  default     = []
}

variable "create_container" {
  type        = bool
  description = "(Optional) Specifies if a Container will created in a Azure Blob Storage Acount. If storage_type is not Blob, this variable will be ignored. By defaults is false."
  default     = false
}

variable "container_name" {
  type        = list(string)
  description = "(Optional) The name of the Container which should be created within the Storage Account. Only apply if create_container is set to true. If not set them the value will be <storage account name>-cont."
  default     = null
}

variable "share_name" {
  type        = string
  description = "(Optional) The name of the share. Must be unique within the storage account where the share is located. If not set them the value will be the name of the Storage Account."
  default     = null
}

variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional) Flag to indicate if you want disable the public network access. Possible values are true or false. By default true."
  default     = true
}


variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "(Optional) The Azure subnets that can access Storage Account."
  default     = []
}

//NetworksACL  
variable "waiver_sp54_STA_NoNetworksACLDefault_value" {
  description = "(Required) Allow/Deny Netwowk ACL for STA Protect firewalls."
  type        = string
  default     = "Deny"
}

// KEY VAULT 
variable "akv_id" {
  type        = string
  description = "(Optional) Specifies the Id of of the common key vault. If key_custom_enabled is true, it's required if akv_name is null."
  default     = null
}

variable "akv_rsg_name" {
  type        = string
  description = "(Optional) Specifies the name of the Resource Group where the key vault is located. If akv_id is set, it will be ignored. If akv_id is null and this variable is not set, it assumes the rsg_name value."
  default     = null
}

variable "akv_name" {
  type        = string
  description = "(Optional) Specifies the name of the common key vault. If key_custom_enabled is true, this variable is required if akv_id is null."
  default     = null
}

variable "key_name" {
  type        = string
  description = "(Optional) The key name used for encryption. If key_custom_enabled is true, this variable must be set."
  default     = null
}

variable "key_exist" {
  type        = bool
  description = "(Optional) Flag to determined if the encryption key exists or not."
  default     = false
}

variable "key_custom_enabled" {
  type        = bool
  description = "(Optional) Flag to determine if the encryption is customized or will be performed by Azure."
  default     = false
}

variable "key_rotation" {
  type        = bool
  description = "(Optional) Flag to determine if the key version rotates automatically or not. In case key_rotation is true the automatic rotation is enabled."
  default     = true
}

variable "expiration_date_key" {
  type        = string
  description = "(Optional) Specifies the time from the moment of creation that the key will expire. By default 100 years."
  default     = "2100-12-31T00:00:01Z"
}

variable "expire_after" {
  type        = string
  description = "(Optional) Expire a Key Vault Key after given duration as an [ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations) If not set, it does not apply."
  default     = null
}

variable "notify_before_expiry" {
  type        = string
  description = "(Optional) Notify at a given duration before expiry as an [ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations). If not set, it does not apply."
  default     = null
}

variable "time_after_creation" {
  type        = string
  description = "(Optional) Rotate automatically at a duration after create as an [ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations)."
  default     = "P90D"
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "(Optional) Boolean flag to specify the way you control access to resources using Azure RBAC is to assign Azure roles. If enable_rbac_authorization is true, the Key Vault Access Policy is not create."
  default     = false
}

// MONITOR DIAGNOSTICS SETTINGS
variable "lwk_rsg_name" {
  type        = string
  description = "(Optional) The name of the resource group where the lwk is located. If this variables is not set, it assumes the rsg_name value."
  default     = null
}

variable "analytics_diagnostic_monitor_lwk_id" {
  type        = string
  description = "(Optional) Specifies the Id of a Log Analytics Workspace where Diagnostics Data should be sent."
  default     = null
}

variable "lwk_name" {
  type        = string
  description = "(Optional) Specifies the name of a Log Analytics Workspace where Diagnostics Data should be sent."
  default     = null
}

variable "analytics_diagnostic_monitor_name" {
  type        = string
  description = "(Optional) The name of the diagnostic monitor. Required if analytics_diagnostic_monitor_enabled is true."
  default     = null
}

variable "analytics_diagnostic_monitor_enabled" {
  type        = bool
  description = "(Optional) Flag to set if the diagnostic monitor is used or not. If the resource deploys in production env, the value will be ignored and asume for it a true value."
  default     = true
}

variable "eventhub_authorization_rule_id" {
  type        = string
  description = "(Optional) Specifies the id of the Authorization Rule of Event Hub used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_namespace" {
  type        = string
  description = "(Optional) Specifies the name of an Event Hub Namespace used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_rsg. It will be ignored if eventhub_authorization_rule_id is defined."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_name" {
  type        = string
  description = "(Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent. Only applies if defined together with analytics_diagnostic_monitor_aeh_rsg and analytics_diagnostic_monitor_aeh_namespace or if defined together eventhub_authorization_rule_id."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_rsg" {
  type        = string
  description = "(Optional) Specifies the name of the resource group where the Event Hub used to send Diagnostics Data is stored. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_namespace. It will be ignored if eventhub_authorization_rule_id is defined."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_policy" {
  type        = string
  description = "(Optional) Specifies the name of the event hub policy used to send diagnostic data. Defaults is RootManageSharedAccessKey."
  default     = "RootManageSharedAccessKey"
}

variable "analytics_diagnostic_monitor_sta_id" {
  type        = string
  description = "(Optional) Specifies the id of the Storage Account where logs should be sent."
  default     = null
}

variable "analytics_diagnostic_monitor_sta_name" {
  type        = string
  description = "(Optional) Specifies the name of the Storage Account where logs should be sent. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_rsg is not null and analytics_diagnostic_monitor_sta_id is null."
  default     = null
}

variable "analytics_diagnostic_monitor_sta_rsg" {
  type        = string
  description = "(Optional) Specifies the name of the resource group where Storage Account is stored. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_name is not null and analytics_diagnostic_monitor_sta_id is null."
  default     = null
}

//NAMING VARIABLES
variable "entity" {
  description = "(Required) Name client. Used for Naming. (6 characters) "
  type        = string
}

variable "environment" {
  description = "(Required)  Environment code. Used for Naming (dev, pre, pro). (3 characters) "
  type        = string
}

variable "app_name" {
  description = "(Required) App name of the resource. Used for Naming. ( 3 characters) "
  type        = string
}

variable "sequence_number" {
  description = "(Required) Sequence number of the resource. Used for Naming. (3 characters) "
  type        = string
}

// TAGGING 
variable "inherit" {
  type        = bool
  description = "(Required) Inherits resource group tags. Values can be false (by default) or true."
  default     = true
}

variable "product" {
  type        = string
  description = "(Required) The product tag will indicate the product to which the associated resource belongs to. In case shared_costs is Yes, product variable can be empty."
  default     = null
}

variable "cost_center" {
  type        = string
  description = "(Required) This tag will report the cost center of the resource. In case shared_costs is Yes, cost_center variable can be empty."
  default     = null
}

variable "shared_costs" {
  type        = string
  description = "(Optional) Helps to identify costs which cannot be allocated to a unique cost center, therefore facilitates to detect resources which require subsequent cost allocation and cost sharing between different payers."
  default     = "No"
  validation {
    condition     = var.shared_costs == "Yes" || var.shared_costs == "No"
    error_message = "Only `Yes`, `No` or empty values are allowed."
  }
}

variable "apm_functional" {
  type        = string
  description = "(Optional) Allows to identify to which functional application the resource belong, and its value must match with existing functional application code in Entity application portfolio management (APM) systems. In case shared_costs is Yes, apm_functional variable can be empty."
  default     = null
}

variable "cia" {
  type        = string
  description = "(Required) Allows a proper data classification to be attached to the resource."
  validation {
    condition     = length(var.cia) == 3 && contains(["C", "B", "A", "X"], substr(var.cia, 0, 1)) && contains(["L", "M", "H", "X"], substr(var.cia, 1, 1)) && contains(["L", "M", "C", "X"], substr(var.cia, 2, 1))
    error_message = "CIA must be a 3 character long and has to comply with the CIA nomenclature (CLL, BLM, AHM...). In sandbox this variable does not apply."
  }
  default = "XXX"
}

variable "optional_tags" {
  type = object({
    entity                = optional(string)
    environment           = optional(string)
    APM_technical         = optional(string)
    business_service      = optional(string)
    service_component     = optional(string)
    description           = optional(string)
    management_level      = optional(string)
    AutoStartStopSchedule = optional(string)
    tracking_code         = optional(string)
    Appliance             = optional(string)
    Patch                 = optional(string)
    backup                = optional(string)
    bckpolicy             = optional(string)
  })
  description = "(Optional) A object with the [optional tags](https://santandernet.sharepoint.com/sites/SantanderPlatforms/SitePages/Naming_and_Tagging_Building_Block_178930012.aspx?OR=Teams-HL&CT=1716801658655&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yNDA1MDMwNTAwMCIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D#optional-tags). These are: entity: (Optional) this tag allows to identify entity resources in a simpler and more flexible way than naming convention, facilitating cost reporting among others; environment: (Optional) this tag allows to identify to which environment belongs a resource in a simpler and more flexible way than naming convention, which is key, for example, to proper apply cost optimization measures; APM_technical: (Optional) this tag allows to identify to which technical application the resource belong, and its value must match with existing technical application code in entity application portfolio management (APM) systems; business_service: (Optional) this tag allows to identify to which Business Service the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); service_component: (Optional) this tag allows to identify to which Service Component the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); description: (Optional) this tag provides additional information about the resource function, the workload to which it belongs, etc; management_level: (Optional) this tag depicts the deployment model of the cloud service (IaaS, CaaS, PaaS and SaaS) and helps generate meaningful cloud adoption KPIs to track cloud strategy implementation, for example: IaaS vs. PaaS; AutoStartStopSchedule: (Optional) this tag facilitates to implement a process to automatically start/stop virtual machines according to a schedule. As part of global FinOps practice, there are scripts available to implement auto start/stop mechanisms; tracking_code: (Optional) this tag will allow matching of resources against other internal inventory systems; Appliance: (Optional) this tag identifies if the IaaS asset is an appliance resource. Hardening and agents installation cannot be installed on this resources; Patch: (Optional) this tag is used to identify all the assets operated by Global Public Cloud team that would be updated in the next maintenance window; backup: (Optional) used to define if backup is needed (yes/no value); bckpolicy: (Optional) (platinium_001 | gold_001 | silver_001 | bronze_001) used to indicate the backup plan required for that resource."
  default = {
    entity                = null
    environment           = null
    APM_technical         = null
    business_service      = null
    service_component     = null
    description           = null
    management_level      = null
    AutoStartStopSchedule = null
    tracking_code         = null
    Appliance             = null
    Patch                 = null
    backup                = null
    bckpolicy             = null
  }
}
variable "custom_tags" {
  type        = map(string)
  description = "(Optional) Custom tags for product."
  default     = {}
}
