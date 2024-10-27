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
    command = var.webapp_build_command
  }
  depends_on = [azurerm_linux_web_app.linux_webapp]
}

# wait for 5m between creation and deployment
resource "time_sleep" "wait_after_webapp_creation" {
  depends_on      = [azurerm_linux_web_app.linux_webapp]
  create_duration = "5m"
}

#use following to update any appsettings that are not set during webapp creation
#   az webapp config appsettings set --resource-group <group-name> --name <app-name> --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true
#Following is th enew command to deploy zip file. However there is currently a bug that causes 504 timeout errors so reverted to the old command "az webapp deployment source config-zip"
#      az webapp deploy --resource-group ${var.resource_group_name} --name ${var.webapp_name} --src-path ${one(data.archive_file.file_function[*].output_path)} --type zip --timeout 600000

resource "null_resource" "linux_webapp_deployment" {
  count = var.webapp_code_path != "" ? 1 : 0

  triggers = {
    file = one(data.archive_file.file_function[*].output_base64sha256)
  }

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${var.subscription_id != "" ? "az account set -s ${var.subscription_id}" : ""}
      az webapp deployment source config-zip --resource-group ${var.resource_group_name} --name ${var.webapp_name} --src ${one(data.archive_file.file_function[*].output_path)} --timeout 900
      ${format(local.delete_file_command, one(data.archive_file.file_function[*].output_path))}
    EOT
  }
  depends_on = [time_sleep.wait_after_webapp_creation, null_resource.linux_webapp_build]
}
