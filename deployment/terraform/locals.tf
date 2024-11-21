# Abbreviations from JSON file (represented as Terraform locals)
locals {
  abbrs = jsondecode(file("abbreviations.json"))
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

# Random ID Generator
resource "random_id" "random" {
  keepers = {
    env_name = var.environment_name
  }
  byte_length = 4
}
