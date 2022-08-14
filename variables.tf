variable "client_id" {
  description = "The Azure service principal ID"
  type        = string
  default     = data.azurerm_client_config.current.client_id
}

variable "subscription_id" {
  description = "The Azure subscription the app sits under"
  type        = string
  default     = data.azurerm_client_config.current.subscription_id
}

variable "tenant_id" {
  description = "The Azure tenant the app is associated with"
  type        = string
  default     = data.azurerm_client_config.current.tenant_id
}

variable "client_secret" {
  description = "The Azure service principal password/secret"
  type        = string
  default     = data.azurerm_client_config.current.client_secret
}