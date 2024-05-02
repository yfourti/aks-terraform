variable "resource_group_location" {
  default = "West US"
}

variable "agent_count" {
  default = 3
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "k8sguru"
}

variable "cluster_name" {
  default = "k8sguru"
}

variable "aks_service_principal_app_id" {
  default = "dc31ff3c-5237-4374-9ddb-12d69c2745c6"
}

# variable "aks_service_principal_client_secret" {
#   default = "Wpz8Q~IN42AxWbjoGKbEg3MRHHsywNDjnHw8ja_A"
# }