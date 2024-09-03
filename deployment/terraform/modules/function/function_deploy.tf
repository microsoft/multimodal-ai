locals {
  is_windows      = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
  windows_command = "az functionapp deployment source config-zip --resource-group rg-mmai-f1486904 --name backend-f1486904 --src ${replace(one(data.archive_file.file_function[*].output_path), "/", "\\")} --build-remote true  ^&  del ${replace(one(data.archive_file.file_function[*].output_path), "/", "\\")}"
  linux_command   = <<-EOT
          az functionapp deployment source config-zip --resource-group rg-mmai-f1486904 --name backend-f1486904 --src ${one(data.archive_file.file_function[*].output_path)} --build-remote true
          rm -f ${one(data.archive_file.file_function[*].output_path)}
EOT
}

resource "null_resource" "linux_function_app_deployment" {
  count = var.function_code_path != "" ? 1 : 0

  triggers = {
    file = one(data.archive_file.file_function[*].output_base64sha256)
  }

  provisioner "local-exec" {
    command = local.is_windows ? local.windows_command : local.linux_command
  }
}
