output "evesrv_name" {
    value = join("", [local.eveDnsLabel, ".",var.location, ".", "cloudapp.azure.com"])
}
output "eve_ip" {
    value = azurerm.azurerm_public_ip.eve_ip
}
output "slb_ip" {
    value = azurerm.azurerm_public_ip.slb_ip
}