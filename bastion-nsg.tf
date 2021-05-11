resource "azurerm_network_security_group" "bastion" {
  name       =    "bastion-nsg"
  resource_group_name = azurerm_resource_group.project.name
  location   =    var.location

  security_rule {
    access = "Allow"
    description = "Allow traffic on port 22 for remote administration"
    destination_address_prefix = "*"
    destination_port_range = "22"
    direction = "Inbound"
    name = "AllowSSHInbound"
    priority = 101
    protocol = "Tcp"
    source_address_prefix = "*"
    source_port_range = "*"

  }

  security_rule {
    access = "Allow"
    description = "Allow traffic on port 443 from Internet"
    destination_address_prefix = "*"
    destination_port_range = "443"
    direction = "Inbound"
    name = "AllowHttpsInbound"
    priority = 110
    protocol = "Tcp"
    source_address_prefix = "Internet"
    source_port_range = "*"

  }
  security_rule {
    access = "Allow"
    description = "Allow traffic on port 443 for Gateway Manager"
    destination_address_prefix = "*"
    destination_port_range = "443"
    direction = "Inbound"
    name = "AllowGatewayManagerInbound"
    priority = 120
    protocol = "Tcp"
    source_address_prefix = "GatewayManager"
    source_port_range = "*"
  }

  security_rule {
    access = "Allow"
    description = "Allow traffic on port 443 for the Azure Load Balancer"
    destination_address_prefix = "*"
    destination_port_range = "443"
    direction = "Inbound"
    name = "AllowAzureLoadBalancerInbound"
    priority = 130
    protocol = "Tcp"
    source_address_prefix = "AzureLoadBalancer"
    source_port_range = "*"
  }

  security_rule {
    access = "Allow"
    description = "Allow traffic from the VNET for the Bastion components"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges = ["8080", "5701"]
    direction = "Inbound"
    name = "AllowBastionHostCommunication"
    priority = 140
    protocol = "Any"
    source_address_prefix = "VirtualNetwork"
    source_port_range = "*"
  }

  security_rule {
    access = "Allow"
    description = "Allow traffic to other target VM subnets for port 3389 and 22."
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges = ["3389", "22"]
    direction = "Outbound"
    name = "AllowSshRdpOutbound"
    priority = 110
    protocol = "Any"
    source_address_prefix = "*"
    source_port_range = "*"
  }

  security_rule {
    access = "Allow"
    description = "Azure Bastion needs outbound to 443 to AzureCloud service tag"
    destination_address_prefix = "AzureCloud"
    destination_port_range = "443"
    direction = "Outbound"
    name = "AllowAzureCloudOutbound"
    priority = 120
    protocol = "Tcp"
    source_address_prefix = "*"
    source_port_range = "*"
  }

  security_rule {
    access = "Allow"
    description = "Allows the components of Azure Bastion to talk to each other."
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges = ["8080", "5701"]
    direction = "Outbound"
    name = "AllowBastionCommunicationOutbound"
    priority = 130
    protocol = "Any"
    source_address_prefix = "VirtualNetwork"
    source_port_range = "*"
  }

  security_rule {
    access = "Allow"
    description = "Azure Bastion needs to be able to communicate with the Internet for session and certificate validation"
    destination_address_prefix = "Internet"
    destination_port_range = "80"
    direction = "Outbound"
    name = "AllowGetSessionInformation"
    priority = 140
    protocol = "Any"
    source_address_prefix = "*"
    source_port_range = "*"
  }

  tags = {
    "Resources" = "Bastion"
    "Project"  =  "FTP"
  }
} 