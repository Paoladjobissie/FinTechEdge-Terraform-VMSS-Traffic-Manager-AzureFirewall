# Create Resource Groups
resource "azurerm_resource_group" "east_us_rg" {
  name     = "east-us-rg"
  location = "East US"
}

resource "azurerm_resource_group" "west_us_rg" {
  name     = "west-us-rg"
  location = "West US"
}

# Create Virtual Networks
resource "azurerm_virtual_network" "east_us_vnet" {
  name                = "east-us-vnet"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "west_us_vnet" {
  name                = "west-us-vnet"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  address_space       = ["10.100.0.0/16"]
}

# Define Subnets as Separate Resources
resource "azurerm_subnet" "east_app_subnet" {
  name                 = "east-app-subnet"
  resource_group_name  = azurerm_resource_group.east_us_rg.name
  virtual_network_name = azurerm_virtual_network.east_us_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "east_data_subnet" {
  name                 = "east-data-subnet"
  resource_group_name  = azurerm_resource_group.east_us_rg.name
  virtual_network_name = azurerm_virtual_network.east_us_vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# Subnets for west-us-vnet
resource "azurerm_subnet" "west_app_subnet" {
  name                 = "west-app-subnet"
  resource_group_name  = azurerm_resource_group.west_us_rg.name
  virtual_network_name = azurerm_virtual_network.west_us_vnet.name
  address_prefixes     = ["10.100.3.0/24"]
}

resource "azurerm_subnet" "west_data_subnet" {
  name                 = "west-data-subnet"
  resource_group_name  = azurerm_resource_group.west_us_rg.name
  virtual_network_name = azurerm_virtual_network.west_us_vnet.name
  address_prefixes     = ["10.100.4.0/24"]
}
## Generate SSH Key
#resource "tls_private_key" "ssh" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# Create Network Security Groups
resource "azurerm_network_security_group" "east_us_nsg" {
  name                = "east_us_nsg"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name

  security_rule {
    name                       = "allow_outbound_traffic"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_data_subnet_to_app_subnet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "10.0.3.0/24"
  }
}

resource "azurerm_network_security_group" "west_us_nsg" {
  name                = "west_us_nsg"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  security_rule {
    name                       = "allow_data_subnet_to_app_subnet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.100.4.0/24"
    destination_address_prefix = "10.100.3.0/24"
  }

  security_rule {
    name                       = "allow_outbound_traffic"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
   }
}


# Associate Network Security Groups with app Subnets EAST
resource "azurerm_subnet_network_security_group_association" "east_app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.east_app_subnet.id
  network_security_group_id = azurerm_network_security_group.east_us_nsg.id
}
# WEST
resource "azurerm_subnet_network_security_group_association" "west_app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.west_app_subnet.id
  network_security_group_id = azurerm_network_security_group.west_us_nsg.id
}

# Subnet Association: Attach the NSG to the Database subnet EAST
resource "azurerm_subnet_network_security_group_association" "east_data_nsg_association" {
  subnet_id                 = azurerm_subnet.east_data_subnet.id
  network_security_group_id = azurerm_network_security_group.east_us_nsg.id
}

# Subnet Association: Attach the NSG to the Database subnet WEST
resource "azurerm_subnet_network_security_group_association" "west_data_nsg_association" {
  subnet_id                 = azurerm_subnet.west_data_subnet.id
  network_security_group_id = azurerm_network_security_group.west_us_nsg.id
}
## Output Generated SSH Key
#output "ssh_private_key" {
#  value     = tls_private_key.ssh.private_key_pem
#  sensitive = true
#}

#output "ssh_public_key" {
#  value = tls_private_key.ssh.public_key_openssh
#}

# Traffic Manager Profile east
resource "azurerm_public_ip" "east_public_ip" {
  name                = "east-public-ip"
  location            = azurerm_resource_group.east_us_rg.location
  resource_group_name = azurerm_resource_group.east_us_rg.name
  allocation_method   = "Static"
  domain_name_label   = "east-unique-public-ip"
}

resource "azurerm_traffic_manager_profile" "east_traffic_manager" {
  name                   = "east-traffic-manager"
  resource_group_name    = azurerm_resource_group.east_us_rg.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "east-traffic-manager-dns"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
tags = {
    environment = "Production"
  }
}

#Traffic manager profile west
resource "azurerm_public_ip" "west_public_ip" {
  name                = "west-public-ip"
  location            = azurerm_resource_group.west_us_rg.location
  resource_group_name = azurerm_resource_group.west_us_rg.name
  allocation_method   = "Static"
  domain_name_label   = "west-unique-public-ip"
}
resource "azurerm_traffic_manager_profile" "west_traffic_manager" {
  name                   = "west-traffic-manager"
  resource_group_name    = azurerm_resource_group.west_us_rg.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "west-traffic-manager-dns"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
tags = {
    environment = "Production"
  }
}

# Traffic Manager Azure Endpoint for East Region
resource "azurerm_traffic_manager_azure_endpoint" "east_endpoint" {
  name                = "east-endpoint"
  weight              = 100
  profile_id               = azurerm_traffic_manager_profile.east_traffic_manager.id
  target_resource_id  = azurerm_public_ip.east_public_ip.id
  priority            = 1
}


# West endpoint
resource "azurerm_traffic_manager_azure_endpoint" "west_endpoint" {
  name                 = "west-endpoint"
  profile_id           = azurerm_traffic_manager_profile.west_traffic_manager.id
  weight               = 100
  target_resource_id   = azurerm_public_ip.west_public_ip.id
  priority = 2
  }

