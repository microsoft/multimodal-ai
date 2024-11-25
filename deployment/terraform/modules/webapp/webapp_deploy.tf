locals {
  is_windows     = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
  line_separator = local.is_windows ? "`" : "\\"
  path_separator = local.is_windows ? "\\" : "/"
  escape_char    = local.is_windows ? "`" : ""

  delete_file_command_for_windows = "del %s"
  delete_file_command_for_linux   = "rm %s"
  delete_file_command             = local.is_windows ? local.delete_file_command_for_windows : local.delete_file_command_for_linux
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
      az webapp deploy --resource-group ${var.resource_group_name} --name ${var.webapp_name} --src-path ${one(data.archive_file.file_function[*].output_path)} --type zip --async true --track-status
      ${format(local.delete_file_command, one(data.archive_file.file_function[*].output_path))}
    EOT
  }
  depends_on = [time_sleep.wait_after_webapp_creation, null_resource.linux_webapp_build]
}