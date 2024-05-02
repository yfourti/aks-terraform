resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.dns_prefix

#   linux_profile {
#     admin_username = "ubuntu"
#     ssh_key {
#       key_data = file(var.ssh_public_key)
#     }
#   }

  default_node_pool {
    name            = "agentpool"
    node_count      = var.agent_count
    vm_size         = "Standard_D2s_v3"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

  tags = {
    Environment = "Development"
  }
}