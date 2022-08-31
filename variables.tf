## AZURE RESOURCE MANAGER CREDS ##
variable "ARM_CLIENT_ID" {
  description = "The Azure service principal ID"
  type        = string
  default     = ""
}

variable "ARM_SUBSCRIPTION_ID" {
  description = "The Azure subscription the app sits under"
  type        = string
  default     = ""
}

variable "ARM_TENANT_ID" {
  description = "The Azure tenant the app is associated with"
  type        = string
  default     = ""
}

variable "ARM_CLIENT_SECRET" {
  description = "The Azure service principal password/secret"
  type        = string
  default     = ""
}

## RESOURCES ##
variable "vm_size" {
  description = "The tier of VM being provisioned"
  type        = string
}

variable "vm_stg_account" {
  description = "The storage account type for the VM"
  type        = string
}

variable "environment" {
  description = "The value for the env tag on resources"
  type        = string
  default     = ""
}