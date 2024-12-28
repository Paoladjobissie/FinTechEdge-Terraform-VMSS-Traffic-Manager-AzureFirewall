#output "tls_private_key" {
#  value     = tls_private_key.ssh.private_key_pem
#  sensitive = true
#}
# Traffic Manager FQDN Output
output "traffic_manager_fqdn" {
  description = "Traffic Manager FQDN"
  value = azurerm_traffic_manager_profile.traffic_manager.fqdn
}

