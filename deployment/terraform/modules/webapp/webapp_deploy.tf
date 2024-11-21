locals {
  is_windows     = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
  line_separator = local.is_windows ? "`" : "\\"
  path_separator = local.is_windows ? "\\" : "/"
  escape_char    = local.is_windows ? "`" : ""

  delete_file_command_for_windows = "del %s"
  delete_file_command_for_linux   = "rm %s"
  delete_file_command             = local.is_windows ? local.delete_file_command_for_windows : local.delete_file_command_for_linux

  update_sku_command_for_windows = <<EOT
  $sku_name = az appservice plan show --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --query "sku.name" --output tsv
  if ($sku_name -ieq "B1" -or $sku_name -ieq "B2") {
      az appservice plan update --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --sku B3
      Start-Sleep -Seconds 60
  }
  EOT

  revert_sku_command_for_windows = <<EOT
  $sku_name = az appservice plan show --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --query "sku.name" --output tsv
  if ($sku_name -ine "${var.webapp_sku}") {
      az appservice plan update --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --sku ${var.webapp_sku}
  }
  EOT

  update_sku_command_for_linux = <<EOT
  sku_name=$(az appservice plan show --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --query "sku.name" --output tsv)
  if [[ "$${sku_name,,}" == "b1" || "$${sku_name,,}" == "b2" ]]; then
    az appservice plan update --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --sku B3
    sleep 1m
  fi
  EOT

  revert_sku_command_for_linux = <<EOT
  sku_name=$(az appservice plan show --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --query "sku.name" --output tsv)
  if [[ "$${sku_name,,}" != ${var.webapp_sku} ]]; then
    az appservice plan update --resource-group ${var.resource_group_name} --name ${azurerm_service_plan.service_plan.name} --sku ${var.webapp_sku}
  fi
  EOT

  update_sku_command = local.is_windows ? local.update_sku_command_for_windows : local.update_sku_command_for_linux
  revert_sku_command = local.is_windows ? local.revert_sku_command_for_windows : local.revert_sku_command_for_linux

}


resource "null_resource" "linux_webapp_build" {
  count = var.webapp_code_path != "" ? 1 : 0

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = var.webapp_build_command
  }
  depends_on = [azurerm_linux_web_app.linux_webapp]
}

# wait for 5m between creation and deployment
resource "time_sleep" "wait_after_webapp_creation" {
  depends_on      = [azurerm_linux_web_app.linux_webapp]
  create_duration = "2m"
}


resource "null_resource" "linux_webapp_deployment" {
  count = var.webapp_code_path != "" ? 1 : 0

  triggers = {
    file = one(data.archive_file.file_function[*].output_base64sha256)
  }

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${var.subscription_id != "" ? "az account set -s ${var.subscription_id}" : ""}
      ${local.update_sku_command}
      az webapp deploy --resource-group ${var.resource_group_name} --name ${var.webapp_name} --src-path ${one(data.archive_file.file_function[*].output_path)} --type zip --async true --track-status
      ${format(local.delete_file_command, one(data.archive_file.file_function[*].output_path))}
    EOT
  }
  depends_on = [time_sleep.wait_after_webapp_creation, null_resource.linux_webapp_build]
}

resource "null_resource" "linux_webapp_deployment_cleanup" {
  count = var.webapp_code_path != "" ? 1 : 0

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${var.subscription_id != "" ? "az account set -s ${var.subscription_id}" : ""}
      ${local.revert_sku_command}
    EOT
  }
  depends_on = [null_resource.linux_webapp_deployment]
}
