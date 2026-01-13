// DATA
rsg_name       = "rg-poc-test-001"

location       = "chilecentral"

analytics_diagnostic_monitor_enabled = false
analytics_diagnostic_monitor_name    = "sta-poc-dev-chl-001-adm"


// NAMING VARIABLES
entity         = "sta"
environment    = "dev"
app_acronym    = "poc"
sequence_number = "001"

// TAGGING
custom_tags = {
 app_name ="sta"
 cost_center ="CC-Test" 
 tracking_cod ="POC"
 # Custom tags
 custom_tags = { "1" = "1", "2" = "2" }
}
