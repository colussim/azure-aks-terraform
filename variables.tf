variable "prefix" {
  default = "edb01"
  description = "A prefix used for all resources"
}

variable "location" {
  default     = "West Europe"
  description = "The Azure Region in which all resources should be provisioned"
}

variable "env" {
  default = "prod"
  description = "The Work Environment"
}

variable "k8sversion" {
  default     = "1.23.5"
  description = "The version of Kubernetes"
}

variable "vm_type" {
  default     = "Standard_B2ms"
  description = "The virtual machine sizes"
}
