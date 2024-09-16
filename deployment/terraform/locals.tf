# Abbreviations from JSON file (represented as Terraform locals)
locals {
  abbrs = jsondecode(file("abbreviations.json"))
}

# Generate a unique resource token
locals {
  resourceToken = lower(join("", [random_id.main.hex]))
}

# Define tags for resources
locals {
  tags = {
    "env-name" = var.environment_name
  }
}

# Random ID Generator
resource "random_id" "main" {
  keepers = {
    env_name = var.environment_name
  }
  byte_length = 4
}
