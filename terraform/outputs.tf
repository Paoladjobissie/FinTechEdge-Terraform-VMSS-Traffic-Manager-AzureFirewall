#output "tls_private_key" {
#  value     = tls_private_key.ssh.private_key_pem
#  sensitive = true
#}
# Traffic Manager FQDN Output
output "east_traffic_manager_fqdn" {
  description = "East Traffic Manager FQDN"
  value = azurerm_traffic_manager_profile.east_traffic_manager.fqdn
}
output "west_traffic_manager_fqdn" {
  description = "West Traffic Manager FQDN"
  value = azurerm_traffic_manager_profile.west_traffic_manager.fqdn
}

/*output "subscription_id" {
  value = data.azurerm_subscription.current.id
}*/
output "instrumentation_key" {
  value = azurerm_application_insights.east_test_appinsights.instrumentation_key
     sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.east_test_appinsights.app_id
}
