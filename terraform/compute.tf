# Load Balancer
resource "azurerm_lb" "east_lb" {
  name                = "east-lb"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  sku                 = "Standard"
}

resource "azurerm_lb" "west_lb" {
  name                = "west-lb"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  sku                 = "Standard"
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "east_be_pool" {
  name                = "east-backend-pool"
  loadbalancer_id     = azurerm_lb.east_lb.id
}

resource "azurerm_lb_backend_address_pool" "west_be_pool" {
  name                = "west-backend-pool"
  loadbalancer_id     = azurerm_lb.west_lb.id
}

# VMSS with Autoscaling EAST
#autoscale
resource "azurerm_monitor_autoscale_setting" "east_autoscale" {
  target_resource_id = azurerm_windows_virtual_machine_scale_set.east_vmss.id
  name                = "east-autoscale"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  location            = azurerm_resource_group.east_us_rg.location

  profile {
    name = "cpu-autoscaling"

    capacity {
      minimum = 1
      maximum = 10
      default = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.east_vmss.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 70
        time_grain         = "PT1M"
        time_window        = "PT5M"
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.east_vmss.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 30
        time_grain         = "PT1M"
        time_window        = "PT5M"
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}


#vmss
resource "azurerm_windows_virtual_machine_scale_set" "east_vmss" {
  name                 = "east-vmss"
  resource_group_name  = azurerm_resource_group.east_us_rg.name
  location             = azurerm_resource_group.east_us_rg.location
  sku                  = "Standard_DS1_v2"
  instances            = 2
  admin_password       = "P@55w0rd1234!"
  admin_username       = "adminuser"
  computer_name_prefix = "vm-"
  upgrade_mode         = "Automatic"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "east-vmss-nic"
    primary = true

    ip_configuration {
      name      = "east-vmss-ipconfig"
      primary   = true
      subnet_id = azurerm_subnet.east_app_subnet.id

      # Correcting the load balancer backend address pool IDs
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.east_be_pool.id]
    }
  }
}

# VMSS with Autoscaling WEST
resource "azurerm_monitor_autoscale_setting" "west_autoscale" {
  target_resource_id = azurerm_windows_virtual_machine_scale_set.west_vmss.id
  name                = "west-autoscale"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  location            = azurerm_resource_group.west_us_rg.location

  profile {
    name = "cpu-autoscaling"

    capacity {
      minimum = 1
      maximum = 10
      default = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.west_vmss.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 70
        time_grain         = "PT1M"
        time_window        = "PT5M"
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.west_vmss.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 30
        time_grain         = "PT1M"
        time_window        = "PT5M"
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}


#vmss
resource "azurerm_windows_virtual_machine_scale_set" "west_vmss" {
  name                 = "west-vmss"
  resource_group_name  = azurerm_resource_group.west_us_rg.name
  location             = azurerm_resource_group.west_us_rg.location
  sku                  = "Standard_DS1_v2"
  instances            = 2
  admin_password       = "P@55w0rd1234!"
  admin_username       = "adminuser"
  computer_name_prefix = "vm-"
  upgrade_mode         = "Automatic"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "west-vmss-nic"
    primary = true

    ip_configuration {
      name      = "west-vmss-ipconfig"
      primary   = true
      subnet_id = azurerm_subnet.west_app_subnet.id

      # Correcting the load balancer backend address pool IDs
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.west_be_pool.id]
    }
  }
}

# EAST VMs
# Windows Virtual Machine

resource "azurerm_public_ip" "east_vm_public_ip" {
  name                = "east-vm-public-ip"
  allocation_method   = "Static"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  sku                 = "Basic"
}

resource "azurerm_network_interface" "east_vm_nic" {
  name                = "east-vm-nic"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.east_app_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.east_vm_public_ip.id
  }
}
resource "azurerm_windows_virtual_machine" "east_vm" {
  name                  = "east-vm"
  resource_group_name   = azurerm_resource_group.east_us_rg.name
  location              = azurerm_resource_group.east_us_rg.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "P@55w0rd1234!"

  network_interface_ids = [azurerm_network_interface.east_vm_nic.id]

  os_disk {
    name              = "vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    environment = "Production"
  }
}

#WEST VMs
# Windows Virtual Machine
resource "azurerm_public_ip" "west_vm_public_ip" {
  name                = "west-vm-public-ip"
  allocation_method   = "Static"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  sku                 = "Basic"
}

resource "azurerm_network_interface" "west_vm_nic" {
  name                = "west-vm-nic"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.west_app_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.west_vm_public_ip.id
  }
}
resource "azurerm_windows_virtual_machine" "west_vm" {
  name                  = "west-vm"
  resource_group_name   = azurerm_resource_group.west_us_rg.name
  location              = azurerm_resource_group.west_us_rg.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "P@55w0rd1234!"

  network_interface_ids = [azurerm_network_interface.west_vm_nic.id]

  os_disk {
    name                 = "vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    environment = "Production"
  }
}


# LOG ANALYTIC EAST
resource "azurerm_log_analytics_workspace" "east_log" {
  name                = "east-log"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
# Settings for VMs
resource "azurerm_monitor_diagnostic_setting" "east_vm_diagnostics" {
  name                       = "east-vm-diagnostics"
  target_resource_id         = azurerm_windows_virtual_machine.east_vm.id 
  log_analytics_workspace_id = azurerm_log_analytics_workspace.east_log.id
metric {
  category = "AllMetrics"
  }
 }

# Diagnostic Settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "east_storage_diagnostics" {
  name                       = "east-storage-diagnostics"
  target_resource_id         = azurerm_storage_account.east_storage_account.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.east_log.id

 metric {
  category = "Transaction"
  }
 }

# Diagnostic Settings for Network Interface
resource "azurerm_monitor_diagnostic_setting" "east_network_diagnostics" {
  name                       = "east-network-diagnostics"
  target_resource_id         = azurerm_network_interface.east_vm_nic.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.east_log.id
metric {
  category = "AllMetrics"
  }
 }

# EAST Define METRIC Alert for CPU Usage
resource "azurerm_monitor_action_group" "east_main" {
  name                = "east-actiongroup"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  short_name          = "eastact"

  email_receiver {
    name          = "admin-email"
    email_address = "djobissiepaola@gmail.com"
     use_common_alert_schema = true
  }
}


resource "azurerm_monitor_metric_alert" "diskspaceAlert" {
  name                = "diskspaceAlert"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  scopes              = [azurerm_windows_virtual_machine.east_vm.id ]
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = " Microsoft.Compute/virtualMachines"
    metric_name      = "diskspace"
    skip_metric_validation = true
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

resource "azurerm_monitor_metric_alert" "east_network_latency" {
  name                = "east-network-latency"
  resource_group_name = azurerm_resource_group.east_us_rg.name
  scopes              = [azurerm_windows_virtual_machine.east_vm.id ]
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = " Microsoft.Compute/virtualMachines"
    metric_name      = "network latency"
    skip_metric_validation = true
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

    resource "azurerm_application_insights" "east_test_appinsights" {
  name                = "east-test-appinsights"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  application_type    = "web"
}


# LOG ANALYTIC WEST
resource "azurerm_log_analytics_workspace" "west_log" {
  name                = "west-log"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
# Settings for VMs
resource "azurerm_monitor_diagnostic_setting" "west_vm_diagnostics" {
  name                       = "west-vm-diagnostics"
  target_resource_id         = azurerm_windows_virtual_machine.west_vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.west_log.id
 metric {
  category = "AllMetrics"
  }
}
 

# Diagnostic Settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "west_storage_diagnostics" {
  name                       = "west-storage-diagnostics"
  target_resource_id         = azurerm_storage_account.west_storage_account.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.west_log.id

  metric {
    category = "Transaction"
  }
}


# Diagnostic Settings for Network Interface
resource "azurerm_monitor_diagnostic_setting" "west_network_diagnostics" {
  name                       = "west-network-diagnostics"
  target_resource_id         = azurerm_network_interface.west_vm_nic.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.west_log.id

 metric {
  category = "AllMetrics"
  }
 }
# ACTION GROUP
resource "azurerm_monitor_action_group" "west_main" {
  name                = "west-actiongroup"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  short_name          = "westact"

  email_receiver {
    name          = "admin-email"
    email_address = "djobissiepaola@gmail.com"
     use_common_alert_schema = true
  }
}

# CPU ALERT 
resource "azurerm_monitor_metric_alert" "west_cpu_alert" {
  name                = "WestCPUAlert"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  scopes              = [azurerm_windows_virtual_machine.west_vm.id]
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}
# DISK SPACE ALERT
resource "azurerm_monitor_metric_alert" "west_disk_space_Alert" {
  name                = "westdiskspaceAlert"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  scopes              = [azurerm_windows_virtual_machine.west_vm.id ]
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = " Microsoft.Compute/virtualMachines"
    metric_name      = "diskspace"
    skip_metric_validation = true
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}
# NETWORK LATENCY ALERT
resource "azurerm_monitor_metric_alert" "west_network_latency" {
  name                = "west-network-latency"
  resource_group_name = azurerm_resource_group.west_us_rg.name
  scopes              = [azurerm_windows_virtual_machine.west_vm.id ]
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = " Microsoft.Compute/virtualMachines"
    metric_name      = "network latency"
    skip_metric_validation = true
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

    resource "azurerm_application_insights" "test_appinsights" {
  name                = "test-appinsights"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  application_type    = "web"
}
# AUTOMATION EAST
resource "azurerm_automation_account" "east_automation" {
  name                = "east-automation"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  sku_name            = "Basic"

}

resource "azurerm_automation_runbook" "east_health_check" {
  name                    = "east-health-check"
  location                = azurerm_resource_group.east_us_rg.location
  resource_group_name     = azurerm_resource_group.east_us_rg.name
  automation_account_name = azurerm_automation_account.east_automation.name

  log_verbose             = true
  log_progress            = true
  description             = "Runbook to perform daily health checks."

  publish_content_link {
    uri = "https://raw.githubusercontent.com/Paoladjobissie/FinTechEdge-Terraform-VMSS-Traffic-Manager-AzureFirewall/main/terraform/health_check.ps1"
  }

  runbook_type = "PowerShell"
}

resource "azurerm_automation_runbook" "east_vm_start_stop" {
  name                    = "east-vm-start-stop"
  location                = azurerm_resource_group.east_us_rg.location
  resource_group_name     = azurerm_resource_group.east_us_rg.name
  automation_account_name = azurerm_automation_account.east_automation.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Runbook to start/stop VMs for cost savings."
  publish_content_link {
    uri = "https://github.com/Paoladjobissie/FinTechEdge-Terraform-VMSS-Traffic-Manager-AzureFirewall/blob/main/terraform/health_check.ps1"
  }
  runbook_type            = "PowerShellWorkflow"
}

resource "azurerm_automation_schedule" "east_health_schedule" {
  name                    = "east-health-schedule"
  resource_group_name     = azurerm_resource_group.east_us_rg.name
  automation_account_name = azurerm_automation_account.east_automation.name
  frequency               = "Week"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2025-01-20T00:05:00Z"
  description             = "Runbook for health checks in the East region."
  week_days               = ["Friday"]
}

resource "azurerm_automation_schedule" "east_start_stop_schedule" {
  name                    = "east-start-stop-schedule"
  resource_group_name     = azurerm_resource_group.east_us_rg.name
  automation_account_name = azurerm_automation_account.east_automation.name
  frequency               = "Week"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2025-01-20T02:05:00Z"
  description             = "Daily schedule for VM start/stop runbook."
   week_days               = ["Friday"]
}

/*# Link Runbooks to Schedules
resource "azurerm_automation_job_schedule" "east_health_check_job" {
  automation_account_name = azurerm_automation_account.east_automation.name
  schedule_name           = azurerm_automation_schedule.east_health_schedule.name
  resource_group_name     = azurerm_resource_group.east_us_rg.name
  runbook_name            = azurerm_automation_runbook.east_health_check.name
}

resource "azurerm_automation_job_schedule" "east_vm_start_stop_job" {
  automation_account_name = azurerm_automation_account.east_automation.name
  schedule_name           = azurerm_automation_schedule.east_start_stop_schedule.name
  resource_group_name     = azurerm_resource_group.east_us_rg.name
  runbook_name            = azurerm_automation_runbook.east_vm_start_stop.name
}*/
