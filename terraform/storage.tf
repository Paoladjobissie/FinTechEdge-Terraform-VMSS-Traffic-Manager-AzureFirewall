# Create Storage Account in East Region
resource "azurerm_storage_account" "east_storage_account" {
  name                     = "paoeaststorageaccount"          # Storage account must be globally unique
  resource_group_name      = azurerm_resource_group.east_us_rg.name
  location                 = azurerm_resource_group.east_us_rg.location
  account_tier              = "Standard"
  account_replication_type = "GRS"  # Geo-redundant storage for high availability
  account_kind             = "StorageV2"
  
  }


# EAST
# Create a Recovery Services Vault
resource "azurerm_recovery_services_vault" "east_recovery_vault" {
  name                = "east-recovery-vault"
  location             = azurerm_resource_group.east_us_rg.location
  resource_group_name  = azurerm_resource_group.east_us_rg.name
  sku                  = "Standard"
  
}


# Create a Backup Policy for VMs
resource "azurerm_backup_policy_vm" "east_vm_policy" {
  name                = "east-vm-backup-policy"
  resource_group_name  = azurerm_resource_group.east_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.east_recovery_vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}



# Create a Backup Vault
resource "azurerm_data_protection_backup_vault" "east_blob_backup" {
  name                = "eastbackupvault"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  location            = azurerm_resource_group.east_us_rg.location
  datastore_type     = "VaultStore" 
 redundancy          = "GeoRedundant"


  lifecycle {
    prevent_destroy = false
  }


  }



# Create a Backup Policy for Blob Storage
resource "azurerm_data_protection_backup_policy_blob_storage" "east_blob_storage_policy" {
  name                = "eastblobbackuppolicy"
  vault_id           = azurerm_data_protection_backup_vault.east_blob_backup.id 
  operational_default_retention_duration = "P7D"
  time_zone          = "UTC"

  depends_on = [
        azurerm_data_protection_backup_vault.east_blob_backup
  ]


  lifecycle {
    prevent_destroy = false
  }

}

# Configure Backup for the Storage Account

/*resource "azurerm_data_protection_backup_instance_blob_storage" "east_backup_instance_blob" {
  name              = "eastbackupinstanceblob"
  vault_id          = azurerm_data_protection_backup_vault.east_blob_backup.id 
  location          =  azurerm_resource_group.east_us_rg.location
  backup_policy_id  = azurerm_data_protection_backup_policy_blob_storage.east_blob_storage_policy.id
  storage_account_id = "/subscriptions/659c9195-eeff-450f-86f0-11ec1780f7bb/resourceGroups/east-us-rg/providers/Microsoft.Storage/storageAccounts/paoeaststorageaccount"

   depends_on = [
    azurerm_data_protection_backup_policy_blob_storage.east_blob_storage_policy
  ]
}*/


#WEST
# Create Storage Account in West Region
resource "azurerm_storage_account" "west_storage_account" {
  name                     = "paoweststorageaccount"          # Storage account must be globally unique
  resource_group_name      = azurerm_resource_group.west_us_rg.name
  location                 = azurerm_resource_group.west_us_rg.location
  account_tier              = "Standard"
  account_replication_type = "GRS"  # Geo-redundant storage for high availability
  account_kind             = "StorageV2"
}

# Create a Recovery Services Vault
resource "azurerm_recovery_services_vault" "west_recovery_vault" {
  name                = "west-recovery-vault"
  location             = azurerm_resource_group.west_us_rg.location
  resource_group_name  = azurerm_resource_group.west_us_rg.name
  sku                  = "Standard"
  
}


# Create a Backup Policy for VMs
resource "azurerm_backup_policy_vm" "west_vm_policy" {
  name                = "west-vm-backup-policy"
  resource_group_name  = azurerm_resource_group.west_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.west_recovery_vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}



# Create a Backup Vault
resource "azurerm_data_protection_backup_vault" "west_blob_backup" {
  name                = "westbackupvault"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  location            = azurerm_resource_group.west_us_rg.location
  datastore_type     = "VaultStore" 
 redundancy          = "GeoRedundant"


  lifecycle {
    prevent_destroy = false
  }


  }



# Create a Backup Policy for Blob Storage
resource "azurerm_data_protection_backup_policy_blob_storage" "west_blob_storage_policy" {
  name                = "westblobbackuppolicy"
  vault_id           = azurerm_data_protection_backup_vault.west_blob_backup.id 
  operational_default_retention_duration = "P7D"
  time_zone          = "UTC"

  depends_on = [
        azurerm_data_protection_backup_vault.west_blob_backup
  ]


  lifecycle {
    prevent_destroy = false
  }

}

/*# Configure Backup for the Storage Account

resource "azurerm_data_protection_backup_instance_blob_storage" "west_backup_instance_blob" {
  name              = "westbackupinstanceblob"
  vault_id          = azurerm_data_protection_backup_vault.west_blob_backup.id 
  location          =  azurerm_resource_group.west_us_rg.location
  backup_policy_id  = azurerm_data_protection_backup_policy_blob_storage.west_blob_storage_policy.id
  storage_account_id = "/subscriptions/659c9195-eeff-450f-86f0-11ec1780f7bb/resourceGroups/west-us-rg/providers/Microsoft.Storage/storageAccounts/paoweststorageaccount"

   depends_on = [
    azurerm_data_protection_backup_policy_blob_storage.west_blob_storage_policy
  ]
}*/

/*# SITE RECOVERY FOR FAILOVER
resource "azurerm_site_recovery_fabric" "primary_fabric" {
  name                = "primary-fabric"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.east_recovery_vault.name
  location            = azurerm_resource_group.east_us_rg.location
}

resource "azurerm_site_recovery_fabric" "secondary_fabric" {
  name                = "secondary-fabric"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.west_recovery_vault.name
  location            = azurerm_resource_group.west_us_rg.location
}

resource "azurerm_site_recovery_protection_container" "primary_protection_container" {
  name                 = "primary-protection-container"
  resource_group_name  = azurerm_resource_group.east_us_rg.name
  recovery_vault_name  = azurerm_recovery_services_vault.east_recovery_vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary_fabric.name
}

resource "azurerm_site_recovery_protection_container" "secondary_protection_container" {
  name                 = "secondary-protection-container"
  resource_group_name  = azurerm_resource_group.west_us_rg.name
  recovery_vault_name  = azurerm_recovery_services_vault.west_recovery_vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary_fabric.name
}

resource "azurerm_site_recovery_replication_policy" "replication_policy" {
  name                                                 = "replication-policy"
  resource_group_name                                  = azurerm_resource_group.west_us_rg.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.west_recovery_vault.name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60

}

resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = azurerm_resource_group.west_us_rg.name
  recovery_vault_name                       = azurerm_recovery_services_vault.west_recovery_vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary_fabric.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary_protection_container.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary_protection_container.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.replication_policy.id
}

resource "azurerm_site_recovery_network_mapping" "network-mapping" {
  name                        = "network-mapping"
  resource_group_name         = azurerm_resource_group.west_us_rg.name
  recovery_vault_name         = azurerm_recovery_services_vault.west_recovery_vault.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary_fabric.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary_fabric.name
  source_network_id           = azurerm_virtual_network.east_us_vnet.id
  target_network_id           = azurerm_virtual_network.west_us_vnet.id
}


resource "azurerm_site_recovery_replicated_vm" "vm-replication" {
  name                                      = "vm-replication"
  resource_group_name                       = azurerm_resource_group.east_us_rg.name
  recovery_vault_name                       = azurerm_recovery_services_vault.east_recovery_vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary_fabric.name
  source_vm_id                              = azurerm_windows_virtual_machine.east_vm.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.replication_policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary_protection_container.name

  target_resource_group_id                = azurerm_resource_group.west_us_rg.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary_fabric.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary_protection_container.id
  depends_on = [
    azurerm_site_recovery_fabric.primary_fabric,
    azurerm_site_recovery_fabric.secondary_fabric,
    azurerm_site_recovery_protection_container.primary_protection_container,
    azurerm_site_recovery_protection_container.secondary_protection_container
  ]
}*/

