# **Azure Storage Account**

## Overview

**IMPORTANT** 
* If you want to run this module it is an important requirement to specify the azure provider version, you must set the azure provider version and the terraform version in version.tf file.
* In versions.tf file you must include in provider section: **storage_use_azuread = true**
* If you want deploy a **DataLake** (StorageV2 with hierarchical namespace) you must use Curated Module **terraform-azurerm-module-dls-sm-tfe**

This module has been certified with the versions:

| Terraform version | Azure version | Null version |
|:-----:|:-----:|:-----:|
| 1.8.5 | 3.110.0 | 3.2.3 |

**<span style="color:red; font-weight:bold; animation: blinker 1s linear infinite;">ATTENTION!!!</span>**
<br>Starting in October 2025, access to the Key Vault will be through RBAC instead of access policies.
<br>The value of the enable_rbac_authorization variable should be changed to true instead of using the default value false.
<br>Make sure that the Service Principal that executes it has permission from Santander RBAC Contributor to be able to execute it.

### Acronym
Acronym for the product is **sta**.

## Description
> Azure Files offers fully managed file shares in the cloud that are accessible via the industry standard Server Message Block (SMB) protocol or Network File System (NFS) protocol. Azure file shares can be mounted concurrently by cloud or on-premises deployments. Azure Files SMB file shares are accessible from Windows, Linux, and macOS clients. Azure Files NFS file shares are accessible from Linux or macOS clients. Additionally, Azure Files SMB file shares can be cached on Windows Servers with Azure File Sync for fast access near where the data is being used.

|Configuration|Description|
|:--:|:--:|
|Supported Protocols|NFS, SMB|
|Authentication|Azure AD RBAC model should be used to access resources, **access using SAS Tokens should not be used** (not enforced)|

## Public Documentation
[Azure Storage Files Overview](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction)


## Dependencies

### The AZ Powershell version for this module deployment must be at least 5.7.0

* If it wants to use this module with Terraform Enterprise, this must run using your own agents which will already have Powershell installed.

The following resources must exist before the deployment can take place:

* Azure Subscription.
* Resource Group.
* Azure Active Directory Tenant.
* Azure Storage Account for Security Logs.
* Log Analytics Workspace (formerly OMS) for health logs and metrics.
* A deployment Service Principal with owner permissions on the resource group.
* If it wants to use the Threat Protection in the Storage Account, the threat_protection_enabled variable must be true (defaults to false), and it must be attention that the Classic Defender for Storage can no longer enable since February 5 2025 and it must be updated and migrated to the New Defender for Storage. Review [migrate to the New Defender for Storage Plan](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-classic-migrate), to updated into the Subscription for use Threat Protection in the Storage account. The Classic Plan is no longer available for new subscriptions and storage accounts, subscriptions already using the New or Classic per Storage Account Plans, or re-enabling. If it has enabled the New Plan, disable any Policies attempting to re-enable the Classic Plan.
* A Virtual Network and a Subnet from where to access the product. The subnet must have Microsoft.storage endpoint configured.
* A Key Vault to encrypt the contents of the storage account.
* Azure Storage account which are top-level objects that represent a shared pool of storage.
* If you want replicate objects you must deploy first the destinations STA and after the origin.
* If you want include versioning enabled the account_replication_type must be "ZRS".
* If you want object replication, the storage account origin must be Standard.
* If a key is created in the module, a rotation policy will be established. The key rotates every 90 days, by default, from its creation, which expires after 10 years (this is the maximum that Azure allows).

**IMPORTANT** Some resources, such as secret or key, can support a maximum of 15 tags

**IMPORTANT:**
After deploying this module, the Storage Account cannot be accessed by terraform because the shared key will be disabled (Security Requirement). If you want to connect to a Storage account using terraform you must first enable the shared key access, launch the terraform module and when finished you must disable the shared key access.

## Architecture example:
![Architecture diagram](documentation/architecture_diagram.png "Architecture diagram")

## Networking

### Network topology
![Network diagram](documentation/network_diagram.png "Network diagram")


### Exposed product endpoints
The following endpoints can be used to consume or manage the Certified Product:

#### Management endpoints (Control Plane)
These endpoints will allow to make changes in the configuration of the Certified Service, change permissions or make application deployments.

|EndPoint|IP/URL  |Protocol|Port|Authorization|
|:--:|:--:|:--:|:--:|:--:|
|Azure Resource Management REST API|https://management.azure.com/|HTTPS|443|Azure Active Directory|

#### Consumption endpoints (Data Plane)
These endpoints will allow you to consume the Certified Service from an application perspective.

|EndPoint|IP/URL  |Protocol|Port|Authorization|
|:--:|:--:|:--:|--|:--:|
|Secured public endpoint, configured with a custom name|https://[storage account name].[service].core.windows.net|HTTPS|443|Authentication and Authorization via Azure AD RBAC model|

## Configuration

| Tf Name | Default Value | Type |Mandatory |Others |
|:--:|:--:|:--:|:--:|:--:|
| subscription_id | n/a | `string` | YES | The id of the subscription in which to create the Storage Account. |
| rsg_name | n/a | `string` | YES | The name of the resource group in which to create the Storage Account. |
| location | `null` | `string` | NO | Specifies the supported Azure location where the resource exists. Changing this forces a new product to be created. If not set assume the Resource Group's location. |
| storage_type | "Blob" | `string` | NO | Specifies the storage type that is required. Valid options are Blob and Files_SMB. Defaults to Blob. The Blob option can only be set when the account_kind is set not equal to FileStorage. The Files_SMB option can only be set when the account_kind and account_type are set to FileStorage and Premium. |
| account_kind | `"StorageV2"` | `string` | NO | Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to StorageV2. |
| account_tier | n/a | `string` | YES | Storage account access kind [Standard | Premium]. |
| access_tier | `"Hot"` | `string` | NO | Storage account access tier for BlobStorage accounts [Hot | Cool]. |
| threat_protection_enabled | `false` | `bool` | NO | | Allows to enable (true) or disable (false) the threat protection resource. Defaults to false. |
| shared_access_key_enabled | `false` | `bool` | NO | Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to false. |
| endpoint_resource_ids | `[]` | `list(string)` | NO | A list of the ID of the Azure resources that should be allowed access to the target storage account. |
| last_access_time_enabled | `false` | `bool` | NO | Is the last access time based tracking enabled? Default to false. |
| storage_policy_rules | `[]` | `list(object({name = string enabled = bool filters = list(object({blob_types = list(string) prefix_match = optional(list(string), []) match_blob_index_tag = optional(list(object({name = string operation = optional(string, "==") value = string})), [])})) actions = list(object({base_blob = optional(object({tier_to_cool_after_days_since_modification_greater_than = optional(number, null)tier_to_cool_after_days_since_last_access_time_greater_than = optional(number, null) tier_to_cool_after_days_since_creation_greater_than = optional(number, null) auto_tier_to_hot_from_cool_enabled = optional(bool, null) tier_to_archive_after_days_since_modification_greater_than = optional(number, null)tier_to_archive_after_days_since_last_access_time_greater_than = optional(number, null)tier_to_archive_after_days_since_creation_greater_than = optional(number, null)tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null) delete_after_days_since_modification_greater_than = optional(number, null)delete_after_days_since_last_access_time_greater_than = optional(number, null) delete_after_days_since_creation_greater_than = optional(number, null)}), {}) snapshot = optional(object({change_tier_to_archive_after_days_since_creation = optional(number, null tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null) change_tier_to_cool_after_days_since_creation = optional(number, null) delete_after_days_since_creation_greater_than = optional(number, null)}), {}) version = optional(object({change_tier_to_archive_after_days_since_creation = optional(number, null)tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null) change_tier_to_cool_after_days_since_creation = optional(number, null) delete_after_days_since_creation = optional(number, null)}), {})}))}))` | NO | A rules list to set a policy to manage the Azure Storage Account. Consist of => name: (Required) The name of the rule. Rule name is case-sensitive. It must be unique within a policy; enabled: (Required) Boolean to specify whether the rule is enabled; filters: (Required) Filters to condition the actions to be performed in the rule. (Consists in => blob_types: (Required) An array of predefined values. Valid options are blockBlob and appendBlob; prefix_match: (Optional) An array of strings for prefixes to be matched; match_blob_index_tag: (Optional) A block that defines the blob index tag based filtering for blob objects. The match_blob_index_tag property requires enabling the blobIndex feature with [PSH or CLI commands](https://azure.microsoft.com/en-us/blog/manage-and-find-data-with-blob-index-for-azure-storage-now-in-preview/). (Consists in => name: (Required) The filter tag name used for tag based filtering for blob objects; operation: (Optional) The comparison operator which is used for object comparison and filtering. Possible value is ==. Defaults to ==; value: (Required) The filter tag value used for tag based filtering for blob objects.)); actions: (Required) Actions associated with the rule if filters are applied. (Consists in => base_blob: (Optional) (A block that supports the following => tier_to_cool_after_days_since_modification_greater_than: (Optional) The age in days after last modification to tier blobs to cool storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_cool_after_days_since_last_access_time_greater_than: (Optional) The age in days after last access time to tier blobs to cool storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_cool_after_days_since_creation_greater_than: (Optional) The age in days after creation to cool storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null. The tier_to_cool_after_days_since_modification_greater_than, tier_to_cool_after_days_since_last_access_time_greater_than and tier_to_cool_after_days_since_creation_greater_than can not be set at the same time; auto_tier_to_hot_from_cool_enabled: (Optional) Whether a blob should automatically be tiered from cool back to hot if it's accessed again after being tiered to cool. Defaults to false. The auto_tier_to_hot_from_cool_enabled must be used together with tier_to_cool_after_days_since_last_access_time_greater_than; tier_to_archive_after_days_since_modification_greater_than: (Optional) The age in days after last modification to tier blobs to archive storage. Supports blob currently at Hot or Cool tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_last_access_time_greater_than: (Optional) The age in days after last access time to tier blobs to archive storage. Supports blob currently at Hot or Cool tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_creation_greater_than: (Optional) The age in days after creation to archive storage. Supports blob currently at Hot or Cool tier. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null. The tier_to_archive_after_days_since_modification_greater_than, tier_to_archive_after_days_since_last_access_time_greater_than and tier_to_archive_after_days_since_creation_greater_than can not be set at the same time; tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) The age in days after last tier change to the blobs to skip to be archived. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; delete_after_days_since_modification_greater_than: (Optional) The age in days after last modification to delete the blob. Must be between 0 and 99999. Defaults to null; delete_after_days_since_last_access_time_greater_than: (Optional) The age in days after last access time to delete the blob. Must be between 0 and 99999. Defaults to null; delete_after_days_since_creation_greater_than: (Optional) The age in days after creation to delete the blob. Must be between 0 and 99999. Defaults to null. The delete_after_days_since_modification_greater_than, delete_after_days_since_last_access_time_greater_than and delete_after_days_since_creation_greater_than can not be set at the same time. The last_access_time_enabled must be set to true in order to use tier_to_cool_after_days_since_last_access_time_greater_than, tier_to_archive_after_days_since_last_access_time_greater_than and delete_after_days_since_last_access_time_greater_than.); snapshot: (Optional) (A block that supports the following => change_tier_to_archive_after_days_since_creation: (Optional) The age in days after creation to tier blob snapshot to archive storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) The age in days after last tier change to the blobs to skip to be archived. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; change_tier_to_cool_after_days_since_creation: (Optional) The age in days after creation to tier blob snapshot to cool storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; delete_after_days_since_creation_greater_than: (Optional) The age in days after creation to delete the blob snapshot. Must be between 0 and 99999. Defaults to null.); version: (Optional) (A block that supports the following => change_tier_to_archive_after_days_since_creation: (Optional) The age in days after creation to tier blob version to archive storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) The age in days after last tier change to the blobs to skip to be archved. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; change_tier_to_cool_after_days_since_creation: (Optional) The age in days creation create to tier blob version to cool storage. Must be between 0 and 99999. Not supported for account_replication_type with ZRS value. Defaults to null; delete_after_days_since_creation:  (Optional) The age in days after creation to delete the blob version. Must be between 0 and 99999. Defaults to null.)). |
| account_replication_type | `"ZRS"` | `string` | NO | Storage account replication type [LRS ZRS GRS RAGRS]. ZRS is not supported with cool or archive tiers. |
| destination_id | `null` | `string` | NO | The resource id of the destination storage account. If you are deploying a origin STA with replication you must put the id of the destination storage account. |
| is_hns_enabled | `false` | `bool` | NO | to allow Data Lake GEN 2, you need to set the variable account_kind to StorageV2. Changes this force a new resource. |
| delete_retention_days | `7` | `number` | NO | Specifies the number of days that the blob should be retained, between 1 and 365 days. |
| is_origin | `false` | `bool` | YES | Is the storage acount the origin?  Default to false. |
| versioning_enabled | `null` | `bool` | NO | Is versioning enabled? Default to false. This feature is not available in Premium tier. |
| change_feed_enabled | `null` | `bool` | NO | Is the blob service properties for change feed events enabled? Default to false. This feature is not available in Premium tier. |
| dest_sta_name | `"xxxx"` | `string` | NO | The name of the destination Storage Account to replicate with. It must be of type Blob otherwise it will fail. Required when you deploy a STA origin with replication and destination_id is not setting. |
| subscription_id_destination | `null` | `string` | NO | The id of the subscription in which to create the destination Storage Account. |
| dest_rsg_name | `null` | `string` | NO | The name of the Resource Group where exist the destination Storage Account to replicate with. Required when you deploy a STA origin with replication and destination_id is not setting. |
| dest_container_name | `null` | `string` | NO | The name of the destination Blob Container to replicate with. |
| quota | `5` | `number` | NO | The maximum size of the share, in gigabytes. |
| cross_tenant_replication_enabled | `false` | `bool` | NO | Should cross Tenant replication be enabled? Defaults to false. |
| bypass | `["AzureServices"]` | `list(string)` | NO | Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None. | 
| static_website | `false` | `bool` | NO | Allows to configure static website settings. The default value is false. |
| index_document | `null` | `string` | NO | The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive. Only applies if static_website is true. Defaults to null. |
| error_404_document | `null` | `string` | NO | The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file. Only applies if static_website is true. Defaults to null. |
| rules | `[]` | `list(object({orig_container_name = string dest_container_name = string}))` | NO | The rules of replication that the Storage Account will have. |
| ip_rules | `[]` | `list(any)` | NO | The ranges of IPs to can access Storage Account. |
| create_container | `false`| `bool` | NO | Specifies if a Container will created in a Azure Blob Storage Acount. If storage_type is not Blob, this variable will be ignored. By defaults is false. If you want replication you must set the value to true. |
| container_name | `null` | `list(string)` | NO | The name/s of the Container/s which should be created within the Storage Account. Only apply if create_container is set to true. If not set them the value will be <storage account name>-cont. |
| share_name | `null` | `string` | NO | The name of the share. Must be unique within the storage account where the share is located. If not set them the value will be the name of the Storage Account. |
| public_network_access_enabled | `true` | `bool` | NO | Flag to indicate if you want disable the public network access. Possible values are true or false. By default true. |
| virtual_network_subnet_ids | `[]` | `list(string)` | NO | The Azure subnets that can access Storage Account. |
| waiver_sp54_STA_NoNetworksACLDefault_value | `"Deny"` | `string` | NO | Allow/Deny Netwowk ACL for STA Protect firewalls. |
| akv_id | `null` | `string` | NO | Specifies the Id of of the common key vault. If key_custom_enabled is true, it's required if akv_name is null. |
| akv_rsg_name| `null` | `string` | NO | Specifies the name of the Resource Group where the key vault is located. If akv_id is set, it will be ignored. If akv_id is null and this variable is not set, it assumes the rsg_name value. |
| akv_name| `null` | `string` | NO | Specifies the name of the common key vault. If key_custom_enabled is true, this variable is required if akv_id is null. |
| key_name| `null` | `string` | NO | The key name used for encryption. If key_custom_enabled is true, this variable must be set. |
| key_exist | `false` | `bool` | NO | Flag to determined if the encryption key exists or not. |
| key_custom_enabled | false | `bool` | NO | Flag to determine if the encryption is customized or will be performed by Azure. In case the variable key_exist is true this variable does not apply. |
| key_rotation | `true` | `bool` | NO | Flag to determine if the key version rotates automatically or not. In case key_rotation is true the automatic rotation is enabled. |
| expiration_date_key | `"2100-12-31T00:00:01Z"` | `string` | NO | Specifies the time that the key will expire in UTC format. By default "2100-12-31T00:00:01Z". |
| expire_after | `null` | `string` | NO | Expire a Key Vault Key after given duration as an [ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations) If not set, it does not apply. |
| notify_before_expiry | `null` | `string` | NO | Notify at a given duration before expiry as an [ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations). If not set, it does not apply. |
| time_after_creation | `"P90D"` | `string` | NO | Rotate automatically at a duration after create as an [ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations). |
| enable_rbac_authorization | `false` | `bool` | NO | Boolean flag to specify the way you control access to resources using Azure RBAC is to assign Azure roles. If enable_rbac_authorization is true, the Key Vault Access Policy is not create. |
| analytics_diagnostic_monitor_lwk_id | `null` | `string` | NO | Specifies the Id of a Log Analytics Workspace where Diagnostics Data should be sent. |
| lwk_name| `null` | `string` | NO | Specifies the name of a Log Analytics Workspace where Diagnostics Data should be sent. |
| lwk_rsg_name| `null` | `string` | NO | The name of the resource group where the lwk is located. If this variable is not set, it assumes the rsg_name value. |
| analytics_diagnostic_monitor_name | `null` | `string` | NO | The name of the diagnostic monitor. Required if analytics_diagnostic_monitor_enabled is true. |
| analytics_diagnostic_monitor_enabled | `true` | `bool` | NO | Enable diagnostic monitor with true or false. |
| eventhub_authorization_rule_id | `null` | `string` | NO | Specifies the id of the Authorization Rule of Event Hub used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name. |
| analytics_diagnostic_monitor_aeh_namespace | `null` | `string` | NO | Specifies the name of an Event Hub Namespace used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_rsg. It will be ignored if eventhub_authorization_rule_id is defined. |
| analytics_diagnostic_monitor_aeh_name | `null` | `string` | NO | Specifies the name of the Event Hub where Diagnostics Data should be sent. Only applies if defined together with analytics_diagnostic_monitor_aeh_rsg and analytics_diagnostic_monitor_aeh_namespace or if defined together eventhub_authorization_rule_id. |
| analytics_diagnostic_monitor_aeh_rsg | `null` | `string` | NO | Specifies the name of the resource group where the Event Hub used to send Diagnostics Data is stored. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_namespace. It will be ignored if eventhub_authorization_rule_id is defined. |
| analytics_diagnostic_monitor_aeh_policy | `"RootManageSharedAccessKey"` | `string` | NO | Specifies the name of the event hub policy used to send diagnostic data. Defaults is RootManageSharedAccessKey. |
| analytics_diagnostic_monitor_sta_id | `null` | `string` | NO | Specifies the id of the Storage Account where logs should be sent. |
| analytics_diagnostic_monitor_sta_name | `null` | `string` | NO | Specifies the name of the Storage Account where logs should be sent. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_rsg is not null and analytics_diagnostic_monitor_sta_id is null. |
| analytics_diagnostic_monitor_sta_rsg | `null` | `string` | NO | Specifies the name of the resource group where Storage Account is stored. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_name is not null and analytics_diagnostic_monitor_sta_id is null. | 
| entity | n/a |`string` | YES | Santander entity code. Used for Naming. (3 characters). |
| environment | n/a |`string` | YES | Santander environment code. Used for Naming. (2 characters). |
| app_acronym |n/a |`string` | YES | App acronym of the resource. Used for Naming. (6 characters). |
| function_acronym | n/a |`string` | YES | App function of the resource. Used for Naming. (4 characters). |
| sequence_number| n/a |`string` | YES | Sequence number of the resource. Used for Naming. (3 characters). |
| inherit | `true` | `bool` | YES | Inherits resource group tags. Values can be false (by default) or true. |
| product | n/a | `string` | YES | The product tag will indicate the product to which the associated resource belongs to. In case shared_costs is Yes, product variable can be empty. |
| cost_center | n/a | `string` | YES | This tag will report the cost center of the resource. In case shared_costs is Yes, cost_center variable can be empty. |
| shared_costs | `"No"` | `string` | NO | Helps to identify costs which cannot be allocated to a unique cost center, therefore facilitates to detect resources which require subsequent cost allocation and cost sharing between different payers. |
| apm_functional | n/a | `string` | YES | Allows to identify to which functional application the resource belong, and its value must match with existing functional application code in Entity application portfolio management (APM) systems. In case shared_costs is Yes, apm_functional variable can be empty. |
| cia | n/a | `string` | YES | Confidentiality-Integrity-Availability. Allows a  proper data classification to be attached to the resource. |
| optional_tags | `{entity = null environment = null APM_technical = null business_service = null service_component = null description = null management_level = null AutoStartStopSchedule = null tracking_code = null Appliance = null Patch = null backup = null bckpolicy = null}` | `object({entity = optional(string) environment = optional(string) APM_technical = optional(string) business_service = optional(string)  service_component = optional(string) description = optional(string) management_level = optional(string) AutoStartStopSchedule = optional(string) tracking_code = optional(string) Appliance = optional(string) Patch = optional(string) backup = optional(string) bckpolicy = optional(string)})` | NO | A object with the [optional tags](https://santandernet.sharepoint.com/sites/SantanderPlatforms/SitePages/Naming_and_Tagging_Building_Block_178930012.aspx?OR=Teams-HL&CT=1716801658655&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yNDA1MDMwNTAwMCIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D#optional-tags). These are: entity: (Optional) this tag allows to identify entity resources in a simpler and more flexible way than naming convention, facilitating cost reporting among others; environment: (Optional) this tag allows to identify to which environment belongs a resource in a simpler and more flexible way than naming convention, which is key, for example, to proper apply cost optimization measures; APM_technical: (Optional) this tag allows to identify to which technical application the resource belong, and its value must match with existing technical application code in entity application portfolio management (APM) systems; business_service: (Optional) this tag allows to identify to which Business Service the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); service_component: (Optional) this tag allows to identify to which Service Component the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); description: (Optional) this tag provides additional information about the resource function, the workload to which it belongs, etc; management_level: (Optional) this tag depicts the deployment model of the cloud service (IaaS, CaaS, PaaS and SaaS) and helps generate meaningful cloud adoption KPIs to track cloud strategy implementation, for example: IaaS vs. PaaS; AutoStartStopSchedule: (Optional) this tag facilitates to implement a process to automatically start/stop virtual machines according to a schedule. As part of global FinOps practice, there are scripts available to implement auto start/stop mechanisms; tracking_code: (Optional) this tag will allow matching of resources against other internal inventory systems; Appliance: (Optional) this tag identifies if the IaaS asset is an appliance resource. Hardening and agents installation cannot be installed on this resources; Patch: (Optional) this tag is used to identify all the assets operated by Global Public Cloud team that would be updated in the next maintenance window; backup: (Optional) used to define if backup is needed (yes/no value); bckpolicy: (Optional) (platinium_001, gold_001, silver_001, bronze_001) used to indicate the backup plan required for that resource. |
| custom_tags | `{}` | `map(string)` | NO | Custom (additional) tags for compliant.|

## Outputs
|Output Name| Output Value | Description |
|:--:|:--:|:--:|

| sta_id | azurerm_storage_account.storage_account_service[0].id | ID of Storage Account deployed. |
| sta_name | azurerm_storage_account.storage_account_service[0].name | Name of Storage Account deployed. |
| sta_blob_container_id | azurerm_storage_container.blob_container[0].id | ID of Storage Blob Container deployed (If a container is not created this value will be null). |
| sta_blob_container_name | azurerm_storage_container.blob_container[0].id | Name of Storage Blob Container deployed  (If a container is not created this value will be null). |
| sta_share_id | azurerm_storage_share.fileshare[0].id | ID of Storage File Share deployed (If a File Share is not created this value will be null). |
| sta_share_name | azurerm_storage_share.fileshare[0].name | Name of Storage File Share deployed (If a File Share is not created this value will be null). |
| sta_primary_connection_string | azurerm_storage_account.storage_account_service[0].primary_connection_string | The primary conection string of the Storage Account. |
| sta_identity_object_id | azurerm_storage_account.storage_account_service[0].identity[0].principal_id |The Principal ID of the Storage Account Identity. |

<br>

## Usage

Include the next code into your main.tf file:

```hcl
module "sta" {

  source  = "<sta module source>"
  version = "<sta module version>"

  // COMMON VARIABLES
  subscription_id                             = var.subscription_id                               # Required
  rsg_name                                    = var.rsg_name                                      # Required
  location                                    = var.location                                      # Optional

  // PRODUCT
  storage_type                                = var.storage_type                                  # Optional
  account_kind                                = var.account_kind                                  # Optional
  account_tier                                = var.account_tier                                  # Required
  access_tier                                 = var.access_tier                                   # Optional
  threat_protection_enabled                   = var.threat_protection_enabled                     # Optional
  shared_access_key_enabled                   = var.shared_access_key_enabled                     # Optional
  endpoint_resource_ids                       = var.endpoint_resource_ids                         # Optional
  last_access_time_enabled                    = var.last_access_time_enabled                      # Optional
  storage_policy_rules                        = var.storage_policy_rules                          # Optional
  account_replication_type                    = var.account_replication_type                      # Optional
  destination_id                              = var.destination_id                                # Optional
  is_hns_enabled                              = var.is_hns_enabled                                # Optional
  delete_retention_days                       = var.delete_retention_days                         # Optional
  is_origin                                   = var.is_origin                                     # Required
  versioning_enabled                          = var.versioning_enabled                            # Optional
  change_feed_enabled                         = var.change_feed_enabled                           # Optional
  dest_sta_name                               = var.dest_sta_name                                 # Optional
  subscription_id_destination                 = var.subscription_id_destination                   # Optional
  dest_rsg_name                               = var.dest_rsg_name                                 # Optional
  dest_container_name                         = var.dest_container_name                           # Optional
  quota                                       = var.quota                                         # Optional
  cross_tenant_replication_enabled            = var.cross_tenant_replication_enabled              # Optional
  bypass                                      = var.bypass                                        # Optional
  static_website                              = var.static_website                                # Optional
  index_document                              = var.index_document                                # Optional
  error_404_document                          = var.error_404_document                            # Optional
  rules                                       = var.rules                                         # Optional
  ip_rules                                    = var.ip_rules                                      # Optional
  create_container                            = var.create_container                              # Optional
  container_name                              = var.container_name                                # Optional
  share_name                                  = var.share_name                                    # Optional
  public_network_access_enabled               = var.public_network_access_enabled                 # Optional
  virtual_network_subnet_ids                  = var.virtual_network_subnet_ids                    # Optional
  waiver_sp54_STA_NoNetworksACLDefault_value  = var.waiver_sp54_STA_NoNetworksACLDefault_value	  # Optional

  // KEY VAULT  
  akv_id                                      = var.akv_id                                        # Optional
  akv_rsg_name                                = var.akv_rsg_name                                  # Optional
  akv_name                                    = var.akv_name                                      # Optional
  key_name                                    = var.key_name                                      # Optional
  key_exist                                   = var.key_exist                                     # Optional
  key_custom_enabled                          = var.key_custom_enabled                            # Optional
  key_rotation                                = var.key_rotation                                  # Optional
  expiration_date_key                         = var.expiration_date_key                           # Optional
  expire_after                                = var.expire_after                                  # Optional
  notify_before_expiry                        = var.notify_before_expiry                          # Optional
  time_after_creation                         = var.time_after_creation                           # Optional
  enable_rbac_authorization                   = var.enable_rbac_authorization                     # Optional

  // MONITOR DIAGNOSTICS SETTINGS
  lwk_rsg_name                                = var.lwk_rsg_name                                                            # Optional
  analytics_diagnostic_monitor_lwk_id         = var.analytics_diagnostic_monitor_lwk_id                                     # Optional
  lwk_name                                    = var.lwk_name                                                                # Optional
  analytics_diagnostic_monitor_name           = var.analytics_diagnostic_monitor_name                                       # Required if analytics_diagnostic_monitor_enabled is true
  analytics_diagnostic_monitor_enabled        = var.analytics_diagnostic_monitor_enabled                                    # Optional
  eventhub_authorization_rule_id              = var.eventhub_authorization_rule_id                                          # Optional
  analytics_diagnostic_monitor_aeh_namespace  = var.analytics_diagnostic_monitor_aeh_namespace                              # Optional 
  analytics_diagnostic_monitor_aeh_name       = var.analytics_diagnostic_monitor_aeh_name                                   # Optional
  analytics_diagnostic_monitor_aeh_rsg        = var.analytics_diagnostic_monitor_aeh_rsg                                    # Optional
  analytics_diagnostic_monitor_aeh_policy     = var.analytics_diagnostic_monitor_aeh_policy                                 # Optional
  analytics_diagnostic_monitor_sta_id         = var.analytics_diagnostic_monitor_sta_id                                     # Optional
  analytics_diagnostic_monitor_sta_name       = var.analytics_diagnostic_monitor_sta_name                                   # Optional
  analytics_diagnostic_monitor_sta_rsg        = var.analytics_diagnostic_monitor_sta_rsg                                    # Optional


  //NAMING VARIABLES
  entity                                      = var.entity                                        # Required
  environment                                 = var.environment                                   # Required
  app_acronym                                 = var.app_acronym                                   # Required
  function_acronym                            = var.function_acronym                              # Required
  sequence_number                             = var.sequence_number                               # Required

  // TAGGING
  inherit                                     = var.inherit                                       # Required
  product                                     = var.product                                       # Required if shared_costs is No
  cost_center                                 = var.cost_center                                   # Required if shared_costs is No
  shared_costs                                = var.shared_costs                                  # Optional
  apm_functional                              = var.apm_functional                                # Optional
  cia                                         = var.cia                                           # Required
  optional_tags                               = var.optional_tags                                 # Optional
  custom_tags                                 = var.custom_tags                                   # Optional
}
```

Include the next code into your outputs.tf file:

```hcl

output "sta_id" {
  description = "The id of Storage Account deployed."
  value = module.sta.sta_id
  }

output "sta_name" {
  description = "The name of Storage Account deployed."
  value       = module.sta.sta_name
  }

output "sta_blob_container_id" {
  description = "The id of Storage Blob Container deployed (If a container is not created this value will be null)."
  value       = module.sta.sta_blob_container_id
  }

output "sta_blob_container_name" {
  description = "The name of Storage Blob Container deployed  (If a container is not created this value will be null)."
  value       = module.sta.sta_blob_container_name
  }
  
output "sta_share_id" {
  description = "The id of Storage File Share deployed (If a File Share is not created this value will be null)."
  value       = module.sta.sta_share_id
  }

output "sta_share_name" {
  description = "The name of Storage File Share deployed (If a File Share is not created this value will be null)."
  value       = module.sta.sta_share_name
  }

output "sta_primary_connection_string" {
  description = "The primary conection string of the Storage Account."
  value       = module.sta.sta_primary_connection_string
  sensitive   = true
}

output "sta_identity_object_id" {
  description = "The Principal ID of the Storage Account Identity."
  value       = module.sta.sta_identity_object_id
}

```

* You can watch more details about [Storage Account configuration parameters](/variables.tf).


# **Security Framework**
This section explains how the different aspects to have into account in order to meet the Security Control Framework for this Certified Service. 

This product has been certified for the [Security Control Framework v1.2](https://teams.microsoft.com/l/file/E7EFF375-EEFB-4526-A878-3C17A220F63C?tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47&fileType=docx&objectUrl=https%3A%2F%2Fmicrosofteur.sharepoint.com%2Fteams%2FOptimum-SanatanderAzureFoundationsProject%2FShared%20Documents%2FCCoE-Channel%2FSecurity%20Control%20Framework%2FSantander%20-%20CCoE%20-%20Security%20Control%20Framework%20-%20v1.2.docx&baseUrl=https%3A%2F%2Fmicrosofteur.sharepoint.com%2Fteams%2FOptimum-SanatanderAzureFoundationsProject&serviceName=teams&threadId=19:e20a3726dc824141b32579df437f7a66@thread.skype&groupId=26385c5b-85e4-4376-988a-27ed549d9419) revision.

A Whitelist of common IPs has been included in the script. Additional IPs can be included using var.ip_rules. The Latest list of IPs can be found in this [link](https://santandernet.sharepoint.com/:x:/r/sites/globalcloudsecurity/_layouts/15/Doc.aspx?sourcedoc=%7BF8D31875-5A71-4569-A5D6-580EA272FDFD%7D&file=Deny%20policies%20transition%20analysis.xlsx&action=default&mobileredirect=true&DefaultItemOpen=1). If the Ip is not included, the resource will be unavailable.

## Security issues

Product has some missing features which makes it not fully compliant to cybersecurity policies:
 - Network Segmentation
 - Network Protection
 - IAM

Private-Link feature is in roadmap: Q3CY19

CMEK issue: Q4CY19 for BLOB

Egress issue: n/a

### Public-endpoint

 - Blob Storage: https://[instance name].blob.core.windows.net
 - Table Storage: https://[instance name].table.core.windows.net/
 - Queue Storage: https:// [instance name].queue.windows.net
 - File Storage: https:// [instance name].file.windows.net

Public domain name + public IPv4

https://docs.microsoft.com/es-es/azure/storage/common/storage-network-security

PUBLIC PREVIEW

The following link lists the Private Link services and the regions where they are available.

https://docs.microsoft.com/en-us/azure/private-link/private-link-overview#availability

### Internal RBAC model

RBAC model available per Storage Account internal resource type:

 - Blobs: AzureAD IAM – OK
 - Files: AzureAD IAM - OK (only SMB)
 - Tables: non AzureAD IAM – issue
 - Queues: optional AzureAD IAM – issue

Azure Files supports authorization with Azure AD over SMB for domain-joined VMs only.

https://docs.microsoft.com/bs-latn-ba/azure/storage/common/storage-auth-aad#azure-ad-authorization-over-smb-for-azure-files

Shared Access Signature (SAS) is an alternative way of authenticating & authorizing requests.

## Security Controls based on Security Control Framework

### Foundation (**F**) Controls for Rated Workloads
|SF#|What|How it is implemented in the Product|Who|
|:--:|:---:|:---:|:--:|
|SF1|IAM on all accounts|Azure AD RBAC model for products certifies right level of access to resource.<br>Review design patter for Domain Services for more information: [[CLOPC] ABB IAM - Domain Services](https://confluence.alm.europe.cloudcenter.corp/display/ARCHSEC/%5BCLOPC%5D+ABB+IAM+-+Domain+Services)<br>Shared Key Access is disabled for the certified module.|CCoE<br>Entity<br>|
|SF2|MFA on account|This is governed by Azure AD.|CISO<br>CCoE<br>Entity<br>|
|SF3|Platform Activity Logs & Security Monitoring	|Platform logs and security monitoring provided by Platform. Azure Security Center and Azure Defender for Storage may be used for security monitoring on the Paas, although this is not enforced.|CISO<br>CCoE<br>Entity<br>|
|SF4|Malware Protection on IaaS	|Since this is a **PaaS** service, Malware Protection on IaaS doesn't apply.|CISO<br>CCoE<br>Entity<br>|
|SF5|Authenticate all connections|Since this is a **PaaS** service, server certificate is configured by CSP. User authentication is done via Azure Active Directory. Anonimous authentication is disabled in certified product.|CCoE<br>Entity<br>
|SF6|Isolated environments at network level|As Private Link doesn't support NSGs, traffic must be redirected to Protect Firewall to be controlled.<br><br>Access without using Private Link is allowed in the certified product for the followins origin IPs: OnPremise, VPN, SPN_API and Campus_Proxy. CCoE and Entity may configure this filtering in depth if required.|CISO<br>CCoE<br>Entity<br>|
|SF7|Security Configuration & Patch Management|Since this is a **PaaS** service, product upgrade and patching is done by CSP.|CCoE<br>Entity<br>|
|SF8|Privileged Access Management|**Data Plane**: Access to data plane is not considered Privileged Access<br>**Control Plane**: Access to the control plane is considered Privileged Access and is governed as per the Azure Management Endpoint Privileged Access Management policy.|CISO<br>CCoE<br>|


### Application (**P**) Controls for Rated Workloads
|SP#|What|How it is implemented in the Product|Who|
|:--:|:---:|:---:|:--:|
|SP1|Resource tagging for all resources|Product includes all required tags in the deployment template|CISO<br>CCoE<br>|
|SP2|Segregation of Duties|N/A|CISO<br>CCoE<br>Entity<br>|
|SP3|Vulnerability Management|Since this is a **PaaS** service, Vulnerability Management is done by CSP	|CISO<br>CCoE<br>Entity<br>|
|SP4|Service Logs and Security Monitoring|Product is connected to Log Analytics for activity and security monitoring. Azure Security Center and Azure Defender for Storage may be used for security monitoring on the Paas, although this is not enforced.|CISO<br>CCoE<br>Entity<br>|
|SP5|Network Security|The STA will be configured with a Private Endpoint, which uses a private IP address from a defined VNet, effectively bringing the STA service into the VNet in which the Private Endpoint is deployed. Access without using Private Link is allowed in the certified product for the followins origin IPs: OnPremise, VPN, SPN_API and Campus_Proxy. CCoE and Entity may configure this filtering in depth if required.<br>**SP5.1**:  The product's virtual firewall allows OnPrem connectivity. Devops team is responsible for configuring the virtual firewall of the product to restrict access from onpremise. There is no connectivity from PaaS to onprem.<br>**SP5.2**:Devops team is responsible for configuring the virtual firewall of the product to allow required connectivity between CSP Private Zones of different entities. **SP5.3**:  Devops team is responsible for configuring the virtual firewall of the product to allow required connectivity between CSP Private Zones of the same entity.<br>**SP5.4**: The product's virtual firewall denies incoming connections allowing only access from onPrem, Campus Proxy, VPN and SPN API.<br>**SP5.5**: Doesn't apply as no outbound traffic is generated from the service.<br>**SP5.6**: Doesn't apply.|CISO<br>CCoE<br>Entity<br>|
|SP6|Advanced Malware Protection on IaaS|Since this is a **PaaS**Since this is a **PaaS** service, Advanced Malware Protection on IaaS doesn't apply.|CISO<br>CCoE<br>Entity<br>|
|SP7|Cyber incidents management & Digital evidences gathering|Isolate infrastructure product is possible with product's virtual firewall.|CISO<br>Entity<br>|
|SP8|Encrypt data in transit over public interconnections|Certified Product enables only https traffic and TLS variable is setted to 1.2.|CCoE<br>Entity<br>|
|SP9|Static Application Security Testing|Since there is no applicaton code in this PaaS service, Static Application Security Testing doesn't apply.|Entity|

### Medium (**M**) Controls for Rated Workloads
|SM#|What|How it is implemented in the Product|Who|
|:--:|:---:|:---:|:--:|
|SM1|IAM|Azure AD RBAC model for products certifies right level of access to resource.<br>Review design patter for Domain Services for more information:[[CLOPC] ABB IAM - Domain Services](https://confluence.alm.europe.cloudcenter.corp/display/ARCHSEC/%5BCLOPC%5D+ABB+IAM+-+Domain+Services)<br>Shared Key Access is disabled for the certified module.|CCoE<br>Entity<br>|
|SM2|Encrypt data at rest	|Certified Product encrypt data at rest with Santander-managed key. Key Vault is setted during the deployment process.|CCoE|
|SM3|Encrypt data in transit over private interconnections|Certified Product enables only https traffic and TLS variable is setted to 1.2.|CCoE<br>Entity<br>|
|SM4|Control resource geographical location|The product location is inherited from the resource group.|CISO<br>CCoE<br>|

### Advanced (**A**) Controls for Rated Workloads
|SA#|What|How it is implemented in the Product|Who|
|:--:|:---:|:---:|:--:|
|SA1|IAM|Azure AD RBAC model for products certifies right level of access to resource.<br>Review design patter for Domain Services for more information: [[CLOPC] ABB IAM - Domain Services](https://confluence.alm.europe.cloudcenter.corp/display/ARCHSEC/%5BCLOPC%5D+ABB+IAM+-+Domain+Services)<br>Shared Key Access is disabled for the certified module.<br>|CCoE<br>Entity<br>|
|SA2|Encrypt data at rest|Certified Product encrypt data at rest with Santander-managed key. Key Vault is setted during the deployment process.|CCoE|
|SA3|Encrypt data in transit over private interconnections|Certified Product enables only https traffic and TLS variable is setted to 1.2.|CCoE<br>Entity<br>|
|SA4|Santander managed keys with HSM and BYOK|Santander-managed key is used for encrypt data at rest. Key Vault is setted during the deployment process.|CISO<br>CCoE<br>Entity<br>|
|SA5|Control resource geographical location|The product location is inherited from the resource group.|CISO<br>CCoE|
|SA6|Cardholder and auth sensitive data|Entity is responsable to identify workloads and components processing cardholder and auth sensitive data and apply the security measures to comply with the Payment Card Industry Data Security Standard (PCI-DSS).|Entity|
|SA7|Access control to data with MFA|This is governed by Azure AD.|CISO<br>CCoE<br>Entity<br>|

#**Exit Plan**

AzCopy is a command-line utility that you can use to copy blobs or files to or from a storage account. 
* [Get started with AZ Copy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10)
* Please, review the section **Download Files** at [Transfer data with AzCopy and file storage](
https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-files)

# **Basic tf files description** 
This section explain the structure and elements that represent the artifacts of product.
|Folder|Name|Description
|:--:|:--:|:--:|
|Documentation|network_diagram.png|Network topology diagram.|
|Documentation|architecture_diagram.png|Architecture diagram.|
|Documentation|examples|terraform.tfvars|
|Root|README.md|Product documentation file.|
|Root|CHANGELOG.md|Contains the changes added to the new versions of the modules.|
|Root|main.tf|Terraform file to use in pipeline to build and release a product.|
|Root|outputs.tf|Terraform file to use in pipeline to check output.|
|Root|variables.tf|Terraform file to use in pipeline to configure product.|

### Target Audience
|Audience |Purpose  |
|:--:|:--:|
| Cloud Center of Excellence | Understand the Design of this Service. |
| Cybersecurity Hub | Understand how the Security Framework is implemented in this Service and who is responsible of each control. |
| Service Management Hub | Understand how the Service can be managed according to the Service Management Framework. |


# **Links to internal documentation**
**Reference documents** :
- [List of Acronyms](https://santandernet.sharepoint.com/sites/SantanderPlatforms/SitePages/Naming_and_Tagging_Building_Block_178930012.aspx)
- [Product Portfolio](https://github.alm.europe.cloudcenter.corp/pages/sgt-cloudplatform/documentationGlobalHub/eac-az-portfolio.html)

| Template version | 
|:-----:|
| 1.0.15 |
