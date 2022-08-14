variable "client_id" {
  description = "The Azure service principal ID"
  type        = string
  default     = ""
}

variable "subscription_id" {
  description = "The Azure subscription the app sits under"
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "The Azure tenant the app is associated with"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "The Azure service principal password/secret"
  type        = string
  default     = ""
}