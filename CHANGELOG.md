# **Changelog**

## **[v2.2.1 (2025-06-19)]**
### Changes
- `Changed` the rotation policy in key creation to allow setting the expire_after and notify_before_expiry properties (REQ016569132).
- `Updated` rotation_policy section in resource azurerm_key_vault_key resource called generated.
- `Added` expire_after, notify_before_expiry and time_after_creation variables.
- `Updated` README.md.
- `Updated` CHANGELOG.md.


## **[v2.2.0 (2025-03-31)]**
### Changes
- `Added` Include RBAC option.
- `Updated` README.md.
- `Updated` CHANGELOG.md.

## **[v2.1.12 (2025-03-12)]**
### Changes
- `Added` optional select activate threat protection (REQ015516985).
- `Added` threat_protection_enabled" variable (defaults to false).
- `Updated` azurerm_advanced_threat_protection resource called threat_protection.
- `Updated` README.md.
- `Updated` GHANGELOG.md.

## **[v2.1.11 (2025-02-13)]**
### Changes
- `Added` static website functionality (REQ015286755).
- `Added` static_website, index_document & error_404_document variables.
- `Added` tatic_website section in azurerm_storage_account resource called storage_account_service.
- `Updated` README.md.
- `Updated` CHANGELOG.md.

## **[v2.1.10 (2024-12-18)]**
### Changes
- `Tested` with Terraform v1.8.5, Null provider v3.2.3 and Azure provider v3.110.0.
- `Updated` README.md.
- `Updated` CHANGELOG.md.

## **[v2.1.9 (2024-11-29)]**
### Changes
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.1.8 (2024-10-24)]**
### Changes
- `Updated` Rotation policy of key.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.1.7 (2024-10-17)]**
### Changes
- `Updated` Logic of versioning and change feed.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.1.6 (2024-10-08)]**
### Changes
- `Updated` module by CISO requirement (REQ014018194).
- `Added` cross_tenant_replication_enabled variable setting by default to false. 
- `Changed` bypass variable default value from None to AzureServices.
- `Tested` re-apply.
- `Updated` CHANGELOG.md.
- `Updated` README.md.


## **[v2.1.5 (2024-09-17)]**
### Changes
- `Added` Include variables to set properties versioning and change feed (SCTASK16080647).
- `Tested` re-apply.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.1.4 (2024-09-05)]**
### Changes
- `Added` sta_identity_object_id output (REQ013708029).
- `Tested` re-apply.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

 
## **[v2.1.3 (2024-09-03)]**
### Changes
- `Added` shared_access_key_enabled.
- `Updated` shared_access_key_enabled use in azurerm_storage_account called storage_account_service (REQ013677876).
- `Added` rotation policy in azurerm_key_vault_key resource called generated.
- `Tested` re-apply.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.1.2 (2024-07-04)]**
### Changes
- `Updated` Logic of Diagnostic Monitor.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.1.1 (2024-06-05)]**
### Changes
- `Added` Include soft delete to containers.
- `Updated` CHANGELOG.md.


## **[v2.1.0 (2024-05-27)]**
### Changes
- `Added` Property shared_access_key_enabled to false.
- `Added` Optional tags.
- `Updated` Conditions to use inherit tags.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.0.3 (2024-05-14)]**
### Changes
- `Tested` with terraform v1.7.1, null provier v3.2.2 and azure provider v3.90.0.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.0.2 (2024-04-25)]**
- `Updated` permit set private_link access and set policies to the Storage Account (RITM012336708).
- `Added` add private_link_access block in network_rules section at azurerm_storage_account resource.
- `Added` add azurerm_storage_management_policy resource.
- `Added` endpoint_resource_ids variable.
- `Added` last_access_time_enabled variable.
- `Added` storage_policy_rules variable.
- `Updated` README.md.
- `Changed` account_replication_type variable from required to optional to set the ZRS default value.
- `Updated` CHANGELOG.md.
- `Tested` re-apply.


## **[v2.0.1 (2024-04-16)]**
- `Added` primary_connection_string output
- `Updated` README & CHANGELOG

## **[v2.0.0 (2024-03-21)]**
- `Deleted` Condition to use cmk with CIA A and environment pre or pro.
- `Updated` Reference to local.key_cmk to var.key_custom_enabled.
- `Added` analytics_diagnostic_monitor_lwk_id variable.
- `Changed` lwk_name variable from Required to Optional.
- `Changed` lwk_rsg_name variable from Required to Optional.
- `Updated` azurerm_log_analytics_workspace datasource called lwk_principal.
- `Update` Change the treatment of lists so that they do not use indexes (use toset function).
- `Update` Main to set always tags with the correct naming.
- `Updated` CHANGELOG.md.
- `Updated` README.md.
- `Tested` re-apply.

## **[v1.8.7 (2024-01-29)]**
- `Updated` Allow inform the id of sta for diagnostic settings.
- `Changed` code in diagnostic settings by several issues.
- `Added` Workarround for a issue with var.access_tier == "Hot" when var.account_kind == "BlockBlobStorage" (with other values of account_kind this don't occur) in a re-apply. If access_tier variable is set to "Hot"  and account_kind variable is set to "BlockBlobStorage"a change in place is produced several resources in a re-apply, if the access_tier variable is not set (a null value will set the default value that is "Hot"), a re-apply will not occur.
- `Updated` CHANGELOG.md.
- `Updated` README.md.
- `Tested` re-apply.

## **[v1.8.6 (2023-12-18)]**
- `Update` Include functionality of regions.
- `Update` Allow inform the id of event hub authorization rule.
- `Update` CHANGELOG.md
- `Update` README.md

## **[v1.8.5 (2023-11-13)]**
- `Update` README.md
 
## **[v1.8.4 (2023-11-08)]**
- `Added` availability of multiple regions.

## **[v1.8.3 (2023-11-06)]**
- `Updated` Allow create container without specify the name.

## **[v1.8.2 (2023-10-19)]**
- `Added` availability of the Sweden Central region.

## **[v1.8.1 (2023-10-13)]**
- `Added` diagnostic settings

## **v1.8.0 (2023-10-05)**
### Changes
- `Update` Upgrade versions of terraform 1.4.6 and azurerm provider 3.60.0
- `Update` CHANGELOG.md
- `Update` README.md

## **v1.7.8 (2023-09-18)**
### Changes
- `Update` Upgrade versions of terraform and azurerm provider
- `Update` CHANGELOG.md
- `Update` README.md

## **[v1.7.7 (2023-09-04)]**
### Changes
- `Update` Let create more than one container.

## **[v1.7.6 (2023-08-03)]**
### Changes
- `Delete` Delete azure file authentication property.

## **[v1.7.5 (2023-06-14)]**
### Changes
- `Added` Include variable subscription_id.

## **[v1.7.4 (2023-06-02)]**
### Changes
- `Updated` Change naming to unificate with structural modules.

## **[v1.7.3 (2023-05-29)]**
### Changes
- `Updated` log in favour enabled_log.
- `Updated` Deploy STA Premium with LRS replication.

## **[v1.7.2 (2023-05-19)]**
### Changes
- `Updated` Conditions in local tags.

## **[v1.7.1 (2023-05-17)]**
### Changes
- `Added` Property public_network_access_enabled.

## **[v1.7.0 (2023-05-04)]**
### Changes
- `Added` Naming variables.
- `Update` Unificated with structural module.
- `Update` Delete key version to use the last version of key.

## **[v1.6.2 (2023-04-27)]**
### Changes
- `Added` Variable destination_id.
- `Update` Conditions to object replication.

## **[v1.6.1 (2023-03-03)]**
### Changes
- `Added` Inherit variable.
- `Update` module with template version v1.0.6.
- `Update` Check that storage account origin and destination are in the same environment. 

## **[v1.6.0 (2023-01-20)]** 
- `Added` key_cmk local to set use or not cmk.
- `Added` replication_object local to set use or not replication.
- `Added` is_origin to set if the contaner is the origin of the replication.
- `Added` is_hns_enabled to set if hns is enabled or not.
- `Changed` old local tags in favour of new tags.
- `Changed` tags assign in resources from a merged group to local.tags.
- `Changed` resource_group variable name in favour of rsg_name.
- `Changed` name variable name in favour of sta_name.
- `Changed` name variable lwk_resource_group_name in favour of lwk_rsg_name.
- `Changed` name variable kvt_name in favour of akv_name.
- `Added` analytics_diagnostic_monitor_name.
- `Added` analytics_diagnostic_monitor_enabled.
- `Changed` datagenerated data name in favour of key_principal.
- `Changed` generated resource name in favour of key_generate.
- `Changed` kvt resource name in favour of akv_principal.
- `Changed` sta resource name in favour of mds_principal.
- `Update` Readme.md.
- `Update` module with template version v1.0.4.

## **[v1.5.1]**
### Changes
* Terraform v1.3.2
* Azure provider 3.0.2
* Update doc

## **[v1.5.0]**
### Changes
* Permit create Blob and Azure Files over SMB.
* Enable Azure Files Active Directory Domain Services (AADDS) for storage account by default in native code.
* Add location variable.
* Change tfvars file path.
* Update doc.

## **[v1.4.2]**
### Changes
* Test 2 prueba HDInsights Kafka
* fix doc

## **[v1.4.1]**
### Changes
* Test prueba HDInsights Kafka
* fix outputs

## **[v1.4.0]**
### Changes
* Configure account_kind as variable
* Modifications in main to deploy any supported combination between account_kind and account_tier
* Move changelog.md file to root path according to best practices
  
## **[v1.3.1]**
### Changes
* Add new url module whitelist - terraform-azurerm-module-irw

## **[v1.3.0]**
### Changes
* Oficial Module terraform-azurerm-module-sta
* Terraform v1.0.9
* Azure provider 3.0.2
* Delete all reference to variable allow_blob_public_access in azurerm_storage_account as it changes in azure provider 3.0.2: At this time allow_blob_public_access is only supported in the Public Cloud, China Cloud, and US Government Cloud.
* Update key_permissions in azurerm_key_vault_access_policy as the values are case sensitive with azure provider 3.0.2
* Update .gitignore file
* Add changelog.md
* Update README.md


## **[v1.2.1] **
### Changes
* Last release iac.az.modules.storage-account-directory-shared
* update creation of key


## **[v1.2.0] **
### Changes
* Merge pull request #3 from sgt-cloudplatform/tags Custom Tags & fixed script errors


## **[v1.1.0] **
### Changes
* Merge branch 'development' of https://github.alm.europe.cloudcenter.corp/sgt-cloudplatform/iac.az.modules.storage-account-directory-shared into development


## **[v1.0.0] - First Version**
### Changes
* Merge branch 'development' of https://github.alm.europe.cloudcenter.corp/sgt-cloudplatform/iac.az.modules.storage-account-directory-shared into development

