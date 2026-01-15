// DATA
rsg_name       = "rg-poc-test-001"
location       = "chilecentral"

analytics_diagnostic_monitor_enabled = false
analytics_diagnostic_monitor_name    = "sta-poc-dev-chl-001-adm"
subscription_id = "ef0a94be-5750-4ef8-944b-1bbc0cdda800"
account_tier = "Standard"
log_analytics_workspace_id = "/subscriptions/ef0a94be-5750-4ef8-944b-1bbc0cdda800/resourcegroups/rg-poc-test-001/providers/microsoft.operationalinsights/workspaces/lwkchilecentrallwkdev001"
// NAMING VARIABLES
entity         = "sta"
environment    = "dev"
app_acronym    = "poc"
sequence_number = "002"
account_kind             = "StorageV2"
// TAGGING
app_name ="sta"
cost_center ="CC-Test" 
tracking_cod ="POC"
# Custom tags
custom_tags = { "1" = "1", "2" = "2" }

