# Variables
variable resource_group { }
variable location { }
variable vnet_name { }
variable address_space { }
variable tags { }
variable create_vpc { }

# Create Resources
resource "azurerm_virtual_network" "default" {
    count               = var.create_vpc ? 1 : 0
    
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

output vnet_name {
    value = var.create_vpc ? azurerm_virtual_network.default[0].name : null
}

output vnet_id {
    value = var.create_vpc ? azurerm_virtual_network.default[0].id : null
}

output vnet_guid {
    value = var.create_vpc ? azurerm_virtual_network.default[0].guid : null
}

output subnet_id {
    value = var.create_vpc ? azurerm_virtual_network.default[0].subnet[*].id : null
}

output address_space {
    value = var.create_vpc ? azurerm_virtual_network.default[0].address_space : null
}