locals {
  is_windows     = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
  line_separator = local.is_windows ? "`" : "\\"
  path_separator = local.is_windows ? "\\" : "/"
  escape_char    = local.is_windows ? "`" : ""

  delete_file_command_for_windows = "del %s"
  delete_file_command_for_linux   = "rm %s"
  delete_file_command             = local.is_windows ? local.delete_file_command_for_windows : local.delete_file_command_for_linux
}

resource "null_resource" "linux_function_app_deployment" {
  count = var.function_code_path != "" ? 1 : 0

  triggers = {
    file = one(data.archive_file.file_function[*].output_base64sha256)
  }

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    # ${var.subscription_id != "" ? "az account set -s ${var.subscription_id}" : ""}
    command     = <<EOT
      az functionapp update --resource-group ${var.resource_group_name} --name ${var.function_name} --set publicNetworkAccess=Enabled
      az functionapp deployment source config-zip --resource-group ${var.resource_group_name} --name ${var.function_name} --src ${one(data.archive_file.file_function[*].output_path)} --build-remote true
      ${format(local.delete_file_command, one(data.archive_file.file_function[*].output_path))}
      az functionapp update --resource-group ${var.resource_group_name} --name ${var.function_name} --set publicNetworkAccess=Disabled
    EOT
  }
  depends_on = [azurerm_linux_function_app.linux_function_app]
}
