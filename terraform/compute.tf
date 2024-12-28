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
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.west_be_pool.id]
     
    }
  }
}