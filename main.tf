provider "azurerm" {
  features {}
}
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state"
    storage_account_name = "terraformgithubactions"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}


//aks-private-endpoint
# resource "azurerm_private_endpoint" "pe-aks" {
#   name                = "pe-aks"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.privatelinksubnet.id

#   private_service_connection {
#     name                           = "psc-aks"
#     private_connection_resource_id = azurerm_kubernetes_cluster.aks.id
#     subresource_names              = ["registry"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "pdz-aks"
#     private_dns_zone_ids = [azurerm_private_dns_zone.aks.id]
#   }
# }

//aks identity
resource "azurerm_user_assigned_identity" "aksid" {
  name                = "aks-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "aksdnsrole" {
  scope                = azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aksid.principal_id
}

resource "azurerm_role_assignment" "aksvnetrole" {
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aksid.principal_id
}

# resource "azurerm_role_assignment" "acraks" {
#   principal_id         = azurerm_kubernetes_cluster.aks.identi
#   scope                = azurerm_virtual_network.vnet.id
#   role_definition_name = "Network Contributor"
# }


//aks
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aksdemo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemodns"
  private_cluster_enabled = false
  private_dns_zone_id     = azurerm_private_dns_zone.aks.id
  kubernetes_version = "1.27.7"
  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.aksid.id ]
    # user_assigned_identity_id = azurerm_user_assigned_identity.aksid.id
  }

  network_profile {
    network_plugin = "azure"
  }

  default_node_pool {
    name       = "systempool"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
    max_pods = 30
    pod_subnet_id = azurerm_subnet.akspodsubnet.id
    vnet_subnet_id = azurerm_subnet.aksnodesubnet.id
    os_sku = "Ubuntu"
    os_disk_size_gb = 512
  }

  ingress_application_gateway {
    subnet_id = azurerm_subnet.agicsubnet.id
    
  }

  depends_on = [
    azurerm_role_assignment.aksdnsrole,
    azurerm_role_assignment.aksvnetrole,
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "worker" {
  name                  = "worker"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS4_v2" // 假设这是初始的 VM SKU
  node_count            = 2
  max_pods = 30
  pod_subnet_id = azurerm_subnet.akspodsubnet.id
  vnet_subnet_id = azurerm_subnet.aksnodesubnet.id
  os_sku = "Ubuntu"
  os_disk_size_gb = 512

}


resource "azurerm_role_assignment" "agicaks" {
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
}


output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "nodepool_id" {
  value = azurerm_kubernetes_cluster_node_pool.worker.id
}
