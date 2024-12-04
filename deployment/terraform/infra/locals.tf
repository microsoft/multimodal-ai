# Abbreviations from JSON file (represented as Terraform locals)
locals {
  abbrs = jsondecode(file("../abbreviations.json"))
}

# Generate a unique resource token
locals {
  resourceToken = lower(join("", [random_id.random.hex]))
  is_windows    = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
}

# Define tags for resources
locals {
  tags = {
    "env-name" = var.environment_name
  }
}

locals {
  virtual_network = {
    resource_group_name = split("/", var.vnet_id)[4]
    name                = split("/", var.vnet_id)[8]
  }
  network_security_group = {
    resource_group_name = split("/", var.nsg_id)[4]
    name                = split("/", var.nsg_id)[8]
  }
  route_table = {
    resource_group_name = split("/", var.route_table_id)[4]
    name                = split("/", var.route_table_id)[8]
  }
}

# Random ID Generator
resource "random_id" "random" {
  keepers = {
    env_name = var.environment_name
  }
  byte_length = 4
}
