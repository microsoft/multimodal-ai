locals {
  # Naming locals
  prefix = lower(var.environment_name)

  abbrs = jsondecode(file("../abbreviations.json"))

  # DNS variables
  private_dns_zone_names = {
    blob               = "privatelink.blob.core.windows.net",
    file               = "privatelink.file.core.windows.net",
    table              = "privatelink.table.core.windows.net",
    queue              = "privatelink.queue.core.windows.net",
    vault              = "privatelink.vaultcore.azure.net",
    sites              = "privatelink.azurewebsites.net",
    open_ai            = "privatelink.openai.azure.com",
    cognitive_services = "privatelink.cognitiveservices.azure.com",
    ai_search          = "privatelink.search.windows.net",
    monitor            = "privatelink.monitor.azure.com",
    oms_opsinsights    = "privatelink.oms.opinsights.azure.com",
    ods_opsinsights    = "privatelink.ods.opinsights.azure.com",
    automation         = "privatelink.agentsvc.azure-automation.net"
  }
}
