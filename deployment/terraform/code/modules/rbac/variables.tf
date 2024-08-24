variable "roleDefinition_name" {
  description = "The resource group for Azure OpenAI"
  type        = string
}


variable "scope" {
  description = "The resource group for Azure OpenAI"
  type        = string
}

variable "principalId" {
  description = "The principal ID to assign the role to"
  type        = string
}

variable "principalType" {
  description = "The type of the principal"
  type        = string
  default =  "ServicePrincipal"
}