# EAST FIREWALL
resource "azurerm_firewall" "east_firewall" {
  name                = "east-firewall"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard" 
  }


resource "azurerm_public_ip" "east_firewall_ip" {
  name                = "east-firewall-ip"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# WEST FIREWALL
resource "azurerm_firewall" "west_firewall" {
  name                = "west-firewall"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard" 
  }

resource "azurerm_public_ip" "west_firewall_ip" {
  name                = "west-firewall-ip"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

  
/*# Firewall Network Rules East
resource "azurerm_firewall_network_rule_collection" "east_firewall_network_rules" {
  name                = "east-firewall-network-rules"
  azure_firewall_name = azurerm_firewall.east_firewall.name
  resource_group_name = azurerm_resource_group.east_us_rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "Allow-HTTP"
    source_addresses      = ["*"]
    destination_addresses = ["*"]
    destination_ports     = ["80"]
    protocols             = ["TCP"]
  }

  rule {
    name                  = "Allow-HTTPS"
    source_addresses      = ["*"]
    destination_addresses = ["*"]
    destination_ports     = ["443"]
    protocols             = ["TCP"]
  }
}

# Firewall Application Rules East
resource "azurerm_firewall_application_rule_collection" "east_firewall_app_rules" {
  name                = "east-firewall-app-rules"
  azure_firewall_name = azurerm_firewall.east_firewall.name
  resource_group_name = azurerm_resource_group.east_us_rg.name
  priority            = 200
  action              = "Allow"

  rule {
    name       = "Allow-Google"
    source_addresses = ["10.0.0.0/24"]
    fqdn_tags   = ["Google"]

  }
}

# Firewall Network Rules West
resource "azurerm_firewall_network_rule_collection" "west_firewall_network_rules" {
  name                = "west-firewall-network-rules"
  azure_firewall_name = azurerm_firewall.west_firewall.name
  resource_group_name = azurerm_resource_group.west_us_rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "Allow-HTTP"
    source_addresses      = ["*"]
    destination_addresses = ["*"]
    destination_ports     = ["80"]
    protocols             = ["TCP"]
  }

  rule {
    name                  = "Allow-HTTPS"
    source_addresses      = ["*"]
    destination_addresses = ["*"]
    destination_ports     = ["443"]
    protocols             = ["TCP"]
  }
}

# Firewall Application Rules West
resource "azurerm_firewall_application_rule_collection" "west_firewall_app_rules" {
  name                = "west-firewall-app-rules"
  azure_firewall_name = azurerm_firewall.west_firewall.name
  resource_group_name = azurerm_resource_group.west_us_rg.name
  priority            = 200
  action              = "Allow"

  rule {
    name       = "Allow-Google"
    source_addresses = ["10.0.0.0/24"]
    fqdn_tags   = ["Google"]

  }
}*/