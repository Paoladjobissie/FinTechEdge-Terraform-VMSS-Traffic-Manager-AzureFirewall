/*# Fetch the current subscription information
data "azurerm_subscription" "current" {}

data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations" # Adjust this if using a custom policy or specific display name
}

resource "azurerm_policy_definition" "allowed_locations" {
  name         = "allowed-locations-policy"
  policy_type  = "BuiltIn"
  mode         = "Indexed"
  display_name = "Allowed Locations"
  description  = "This policy restrict resource creation to specific regions."
  policy_rule  = <<POLICY_RULE
  {
    "if": {
      "field": "location",
      "notIn": ["eastus","westus"]
    },
    "then": {
      "effect": "deny"
    }
  }
POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  policy_definition_id = azurerm_policy_definition.allowed_locations.id  # Correct reference 
  subscription_id      = data.azurerm_subscription.current.id
}

# Policy Definition for Enforcing "Production" Tag 
  data "azurerm_resource_group" "east_us_rg" {
  name = "east-us-rg"  # Specify the name of the resource group you're targeting
}

data "azurerm_resource_group" "west_us_rg" {
  name = "west-us-rg"  # Specify the name of the resource group you're targeting
}

  resource "azurerm_policy_definition" "production_policy" {
  name         = "production-policy"
  policy_type  = "Custom"
  display_name = "Enforce 'Environment: Production' Tag"
  description  = "Enforces the 'Environment: Production' tag on resources."
  mode         = "All"

  # Corrected policy rule
  policy_rule = <<POLICY
  {
    "if": {
      "anyOf": [
        {
          "field": "tags['Environment']",
          "exists": "false"
        },
        {
          "field": "tags['Environment']",
          "notEquals": "Production"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY
}


resource "azurerm_resource_group_policy_assignment" "production_east_assignment" {
  name                 = "production-east-assignment"
  resource_group_id                = azurerm_resource_group.east_us_rg.id
  policy_definition_id = azurerm_policy_definition.production_east_policy.id
}
data "azurerm_policy_assignment" "production_east_assignment" {
  name     = "production-east-assignment"
  scope_id = data.azurerm_resource_group.east_us_rg.id
}



# Policy Definition for Enforcing "Production" Tag WEST
resource "azurerm_policy_definition" "production_west_policy" {
  name         = "production-west-policy"
  display_name = "Enforce Production West Environment Policy"
  policy_type  = "Custom"
  mode         = "All"
  policy_rule = <<POLICY

  {
    "if": {
      "anyOf": [
        {
          "field": "[concat('tags[', 'Environment', ']')]",
          "exists": "false"
        },
        {
          "field": "[concat('tags[', 'Environment', ']')]",
          "notEquals": "Production"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY
}

resource "azurerm_resource_group_policy_assignment" "production_west_assignment" {
  name                 = "production-west-assignment"
  resource_group_id    = azurerm_resource_group.west_us_rg.id
  policy_definition_id = azurerm_policy_definition.production_west_policy.id
}

data "azurerm_policy_assignment" "production_west_assignment" {
  name     = "production-west-assignment"
  scope_id = data.azurerm_resource_group.west_us_rg.id
}


# restriction SKU 
resource "azurerm_policy_definition" "vm_policy" {
  name         = "vm-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed VM Sizes"
  description  = "This policy restricts the VM sizes that can be used."
  policy_rule  = <<POLICY_RULE
  {
    "if": {
      "field": "Microsoft.Compute/virtualMachines/sku.name",
      "notIn": ["Standard_DS1_v2", "Standard_DS2_v2"]
    },
    "then": {
      "effect": "deny"
    }
  }
POLICY_RULE
}

resource "azurerm_resource_group_policy_assignment" "vm_east_assignment" {
  name                 = "vm-east-assignment"
  resource_group_id    = azurerm_resource_group.east_us_rg.id
  policy_definition_id = azurerm_policy_definition.vm_east_policy.id
}
data "azurerm_policy_assignment" "vm_east_assignment" {
  name     = "vm-east-assignment"
  scope_id = data.azurerm_resource_group.east_us_rg.id
}

# restriction SKU EAST
resource "azurerm_policy_definition" "vm_west_policy" {
  name         = "vm-west-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed VM Sizes"
  description  = "This policy restricts the VM sizes that can be used."
  policy_rule  = <<POLICY_RULE
  {
    "if": {
      "field": "Microsoft.Compute/virtualMachines/sku.name",
      "notIn": ["Standard_DS1_v2", "Standard_DS2_v2"]
    },
    "then": {
      "effect": "deny"
    }
  }
POLICY_RULE
}
resource "azurerm_resource_group_policy_assignment" "vm_west_assignment" {
  name                 = "vm-west-assignment"
  resource_group_id    = azurerm_resource_group.west_us_rg.id
  policy_definition_id = azurerm_policy_definition.vm_west_policy.id
}
data "azurerm_policy_assignment" "vm_west_assignment" {
  name     = "vm-west-assignment"
  scope_id = data.azurerm_resource_group.west_us_rg.id
}*/
