# Create Storage Account in East Region
resource "azurerm_storage_account" "east_storage_account" {
  name                     = "eastappdata"          # Storage account must be globally unique
  resource_group_name      = azurerm_resource_group.east_us_rg.name
  location                 = azurerm_resource_group.east_us_rg.location
  account_tier              = "Standard"
  account_replication_type = "GRS"  # Geo-redundant storage for high availability
  account_kind             = "StorageV2"
  blob_properties {
    # Enable Blob Storage features (e.g., versioning, soft delete)
    versioning_enabled = true
    delete_retention_policy {
      days = 7 # Retain deleted blobs for 7 days

  }
 }
}


/*
#Adding a container to the East US storage account
resource "azurerm_storage_container" "eastus_container1" {
    name                  = "eastuscontainer1"
    storage_account_name  = azure_storage_account.east_storage_account.name
    container_access_type = "private"
}*/

# Azure recovery service vault east
resource "azurerm_recovery_services_vault" "east_vault" {
  name                = "east-recovery-vault"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  sku                 = "Standard"
}
# Azure RSV WEST
resource "azurerm_recovery_services_vault" "west_vault" {
  name                = "west-recovery-vault"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  sku                 = "Standard"
}

# Create Storage Account in West Region
resource "azurerm_storage_account" "west_storage_account" {
  name                     = "westappdata"          # Storage account must be globally unique
  resource_group_name      = azurerm_resource_group.west_us_rg.name
  location                 = azurerm_resource_group.west_us_rg.location
  account_tier              = "Standard"
  account_replication_type = "GRS"  # Geo-redundant storage for high availability
  account_kind             = "StorageV2"
  blob_properties {
    # Enable Blob Storage features (e.g., versioning, soft delete)
    versioning_enabled = true
    delete_retention_policy {
    days = 7 # Retain deleted blobs for 7 days
  }
 }
}

/*
#Adding a container to the West US storage account
resource "azurerm_storage_container" "westus_container1" {
    name                  = "westuscontainer1"
    storage_account_name  = azure_storage_account.west_storage_account.name
    container_access_type = "private"
}*/

# Containers 
resource "azurerm_backup_container_storage_account" "east_container" {
  resource_group_name = azurerm_resource_group.east_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.east_vault.name
  storage_account_id  = azurerm_storage_account.east_storage_account.id
}

resource "azurerm_backup_container_storage_account" "west_container" {
  resource_group_name = azurerm_resource_group.west_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.west_vault.name
  storage_account_id  = azurerm_storage_account.west_storage_account.id
}
/*# Backup Vault for east VM Backups
resource "azurerm_backup_vault" "vm_east_backup_vault" {
  name                = "vm-east-backup-vault"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  location            = azurerm_resource_group.east_us_rg.location
  sku                 = "Standard"
}

# Azure Recovery Services Vault East
resource "azurerm_recovery_services_vault" "blob_east_backup_vault" {
  name                = "blob-east-backup-vault"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  location            = azurerm_resource_group.east_us_rg.location
  sku                 = "Standard"
}

# Backup Policy for east VMs
# Backup Policy for Virtual Machines
resource "azurerm_backup_policy_vm" "vm_east_backup_policy" {
  name                = "vm-east-backup-policy"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_east_backup_vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }

  retention_monthly {
    count    = 12
    weekdays = ["Sunday"]
    weeks     = "Last"
  }

  retention_yearly {
    count = 5
    months = "January"
    weeks  = "First"
    weekdays = ["Sunday"]
  }
}

# Backup Policy for east Blob Storage
resource "azurerm_backup_policy_blob_storage" "blob_east_backup_policy" {
  name                = "blob-east-backup-policy"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_east_backup_vault.name

  schedule {
    frequency = "Daily"
    time      = "23:30"
  }

  retention {
    daily   = 7
    weekly  = 4
    monthly = 12
    yearly  = 5
  }
}

# Backup Vault for west VM Backups
resource "azurerm_backup_vault" "vm_west_backup_vault" {
  name                = "vm-west-backup-vault"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  location            = azurerm_resource_group.west_us_rg.location
  sku                 = "Standard"
}

# Azure Recovery Services Vault West
resource "azurerm_recovery_services_vault" "blob_west_backup_vault" {
  name                = "blob-west-backup-vault"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  location            = azurerm_resource_group.west_us_rg.location
  sku                 = "Standard"
}

# Backup Policy for west VMs
# Backup Policy for Virtual Machines
resource "azurerm_backup_policy_vm" "vm_west_backup_policy" {
  name                = "vm-east-backup-policy"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_west_backup_vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }

  retention_monthly {
    count    = 12
    weekdays = ["Sunday"]
    weeks     = "Last"
  }

  retention_yearly {
    count = 5
    months = "January"
    weeks  = "First"
    weekdays = ["Sunday"]
  }
}

# Backup Policy for west Blob Storage
resource "azurerm_backup_policy_blob_storage" "blob_west_backup_policy" {
  name                = "blob-west-backup-policy"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_west_backup_vault.name

  schedule {
    frequency = "Daily"
    time      = "23:30"
  }

  retention {
    daily   = 7
    weekly  = 4
    monthly = 12
    yearly  = 5
  }
}

# VM Backup Association - East VM
resource "azurerm_backup_protected_vm" "east_vm_backup" {
  resource_group_name = azurerm_resource_group.east_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_east_backup_vault.name
  source_vm_id        = azurerm_windows_virtual_machine_scale_set.east_vmss.id
  backup_policy_id    = azurerm_backup_policy_vm.vm_east_backup_policy.id
}

# VM Backup Association - West VM
resource "azurerm_backup_protected_vm" "west_vm_backup" {
  resource_group_name = azurerm_resource_group.west_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_west_backup_vault.name
  source_vm_id        = azurerm_windows_virtual_machine_scale_set.west_vmss.id
  backup_policy_id    = azurerm_backup_policy_vm.vm_west_backup_policy.id
}

# Blob Storage Backup Association
resource "azurerm_backup_protected_blob_storage" "blob_backup" {
  resource_group_name      = azurerm_resource_group.east_us_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_eastbackup_vault.name
  storage_account_id       = azurerm_storage_account.east_storage_account.id
  backup_policy_blob_id    = azurerm_backup_policy_blob_storage.blob_east_backup_policy.id
}*/