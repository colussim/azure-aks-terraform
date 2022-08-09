#  Main Resource Group #

resource "azurerm_resource_group" "EDB_aks_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Virtual Network Subnet  #

resource "azurerm_virtual_network" "EDB_aks_net" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.EDB_aks_rg.location
  resource_group_name = azurerm_resource_group.EDB_aks_rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "EDB_aks_sb" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.EDB_aks_net.name
  resource_group_name  = azurerm_resource_group.EDB_aks_rg.name
  address_prefixes     = ["10.1.0.0/22"]
}

# Azure Kubernetes Service  #

resource "azurerm_kubernetes_cluster" "EDB_aks_cl" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.EDB_aks_rg.location
  resource_group_name = azurerm_resource_group.EDB_aks_rg.name
  dns_prefix          = "${var.prefix}-aks"
  kubernetes_version = "${var.k8sversion}"

  default_node_pool {
    name                = "${var.prefix}pool"
    node_count          = 2
    orchestrator_version = "${var.k8sversion}"
    vm_size             = "${var.vm_type}"
    type                = "VirtualMachineScaleSets"
    availability_zones  = ["1", "2"]
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4
    os_disk_size_gb     = 50

    vnet_subnet_id = azurerm_subnet.EDB_aks_sb.id
  }

  identity {
    type = "SystemAssigned"
  }

  azure_policy_enabled = false

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "${var.env}"
  }
}

# Public IP for Ingress Controller # 

resource "azurerm_public_ip" "ingress_ip" {
  name                = "AKS-Ingress-Controller"
  resource_group_name = azurerm_resource_group.EDB_aks_rg.name 
  location            = azurerm_resource_group.EDB_aks_rg.location  
  allocation_method   = "Static"
}

# Set Network Security #

resource "azurerm_network_security_group" "network-sg01" {
  name                = "${var.prefix}-sg"
  location            = "${azurerm_resource_group.EDB_aks_rg.location}"
  resource_group_name = "${azurerm_resource_group.EDB_aks_rg.name}"
}

resource "azurerm_network_security_rule" "edb-https" {
  name                        = "edbhttps"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.EDB_aks_rg.name}"
  network_security_group_name = "${azurerm_network_security_group.network-sg01.name}"
}

resource "azurerm_network_security_rule" "edb-pgsql" {
  name                        = "edbpgsl"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.EDB_aks_rg.name
  network_security_group_name = azurerm_network_security_group.network-sg01.name
}

resource "azurerm_network_security_rule" "deny_internet_inbound" {
  name                       = "Deny-internet-Outbound"
  priority                   = "4096" 
  direction                  = "outbound"
  access                     = "Deny"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "Internet"
  resource_group_name         = azurerm_resource_group.EDB_aks_rg.name
  network_security_group_name = azurerm_network_security_group.network-sg01.name 
  depends_on = [
   azurerm_kubernetes_cluster.EDB_aks_cl, helm_release.ingress-nginx 
  ]
}

resource "azurerm_subnet_network_security_group_association" "assoc-edb" {
  subnet_id                 = azurerm_subnet.EDB_aks_sb.id
  network_security_group_id = azurerm_network_security_group.network-sg01.id
depends_on = [
  azurerm_network_security_rule.deny_internet_inbound 
  ]
}
