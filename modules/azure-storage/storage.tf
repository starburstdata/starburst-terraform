# Variables
variable storage_acc_name { }
variable resource_group { }
variable location { }
variable account_tier { }
variable account_replication_type { }
variable storage_type { }
variable tags { }
variable create_bucket { }
variable client_object_id { }

# Create Storage Account
resource "azurerm_storage_account" "default" {
    count                    = var.create_bucket ? 1 : 0

    name                     = var.storage_acc_name
    resource_group_name      = var.resource_group
    location                 = var.location
    account_tier             = var.account_tier
    account_replication_type = var.account_replication_type

    tags                     = var.tags
}

# Create Container
resource "azurerm_storage_container" "default" {
    count                 = var.create_bucket && var.storage_type == "Blob" ? 1 : 0
    
    name                  = "data"
    storage_account_name  = azurerm_storage_account.default[0].name
    container_access_type = "private"
}

# OR

# Create ADLS filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "default" {
    count              = var.create_bucket && var.storage_type == "ADLS" ? 1 : 0

    name               = "data"
    storage_account_id = azurerm_storage_account.default[0].id

}

# Ensure that the SP has access to the storage account
resource "azurerm_role_assignment" "default" {
    count              = var.create_bucket ? 1 : 0

    scope                = azurerm_storage_account.default[0].id
    role_definition_name = "Storage Blob Data Contributor"
    principal_id         = var.client_object_id #data.azurerm_client_config.example.object_id
}

output storage_account_name {
    value = var.create_bucket ? azurerm_storage_account.default[0].name : ""
}

output storage_account_id {
    value = var.create_bucket ? azurerm_storage_account.default[0].id : ""
}

output container_name {
    value = var.create_bucket && var.storage_type == "Blob" ? azurerm_storage_container.default[0].name : ""
}

output fs_name {
    value = var.create_bucket && var.storage_type == "ADLS" ? azurerm_storage_data_lake_gen2_filesystem.default[0].name : ""
}

output primary_dfs_endpoint {
    value = var.create_bucket && var.storage_type == "ADLS" ? azurerm_storage_account.default[0].primary_dfs_endpoint : ""
}

output primary_blob_endpoint {
    value = var.create_bucket && var.storage_type == "Blob" ? azurerm_storage_account.default[0].primary_blob_endpoint : ""
}

output primary_access_key {
    value = var.create_bucket ? azurerm_storage_account.default[0].primary_access_key : ""
    sensitive = true
}