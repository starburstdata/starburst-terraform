# Variables
variable resource_group { }
variable location { }
variable ex_vnet_name { }
variable ex_subnet_name { }
variable vnet_name { }
variable address_space { }
variable tags { }
variable create_vnet { }

# Create Resources
resource "azurerm_virtual_network" "default" {
    count               = var.create_vnet? 1 : 0
    
    name                = var.vnet_name
    location            = var.location
    resource_group_name = var.resource_group
    address_space       = var.address_space

    subnet {
        name           = "default"
        address_prefix = "10.1.1.0/24"
    }

    tags = var.tags
}

data "azurerm_virtual_network" "existing" {
    count                   = var.create_vnet ? 0 : 1

    name                    = var.ex_vnet_name
    resource_group_name     = var.resource_group
}

data "azurerm_subnet" "existing" {
    count                   = var.create_vnet ? 0 : 1

    name                    = var.ex_subnet_name
    virtual_network_name    = data.azurerm_virtual_network.existing[0].name
    resource_group_name     = var.resource_group
}

output vnet_name {
    value = var.create_vnet ? azurerm_virtual_network.default[0].name : data.azurerm_virtual_network.existing[0].name
}

output vnet_id {
    value = var.create_vnet ? azurerm_virtual_network.default[0].id : data.azurerm_virtual_network.existing[0].id
}

output vnet_guid {
    value = var.create_vnet ? azurerm_virtual_network.default[0].guid : data.azurerm_virtual_network.existing[0].guid
}

output subnet_id {
    value = var.create_vnet ? azurerm_virtual_network.default[0].subnet[*].id : data.azurerm_subnet.existing[0].id[*]
}

output address_space {
    value = var.create_vnet ? azurerm_virtual_network.default[0].address_space : data.azurerm_virtual_network.existing[0].address_space
}