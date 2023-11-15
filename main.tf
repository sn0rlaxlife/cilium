resource "azurerm_resource_group" "azurecilium" {
  name     = "azurecilium"
  location = "eastus"
}

resource "azurerm_virtual_network" "azurecilium" {
  name                = "azurecilium-vnet"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.azurecilium.location
  resource_group_name = azurerm_resource_group.azurecilium.name
}

resource "azurerm_subnet" "azureciliumnodes" {
  name                 = "azurecilium-subnet-node"
  resource_group_name  = azurerm_resource_group.azurecilium.name
  virtual_network_name = azurerm_virtual_network.azurecilium.name
  address_prefixes     = ["10.240.0.0/16"]

}

resource "azurerm_subnet" "azureciliumpods" {
  name                 = "azurecilium-subnet-pods"
  resource_group_name  = azurerm_resource_group.azurecilium.name
  virtual_network_name = azurerm_virtual_network.azurecilium.name
  address_prefixes     = ["10.241.0.0/16"]

}

resource "azurerm_kubernetes_cluster" "azurecilium" {
  name                             = "azurecilium"
  location                         = azurerm_resource_group.azurecilium.location
  resource_group_name              = azurerm_resource_group.azurecilium.name
  dns_prefix                       = "azurecilium"
  api_server_authorized_ip_ranges  = ["xx.xx.xx.xx/32"]
  oidc_issuer_enabled              = true
  tags                             = { Environment = "Production" }  

  default_node_pool {
    name                 = "azurecilium"
    node_count           = 2
    vm_size              = "Standard_DS2_v2"
    vnet_subnet_id       = azurerm_subnet.azureciliumnodes.id
    pod_subnet_id        = azurerm_subnet.azureciliumpods.id
    orchestrator_version = "1.28.0"
    os_sku               = "Mariner"
    fips_enabled         = true
  }
  service_mesh_profile {
    mode                             = "Istio"
    internal_ingress_gateway_enabled = true
    external_ingress_gateway_enabled = true
  }
  
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin  = "azure"
    ebpf_data_plane = "cilium"
  }
}