################## Locals ###############

locals {
  instance_count = 2
  eveDnsLabel = "lecedeve89"
  vmOffer = "UbuntuServer"
  eveSKU = "16.04-LTS"
  ftpSKU = "20.04-LTS"
}

########## Creation of NSG and security rules #########

resource "azurerm_network_security_group" "ftp" {
  name       =    "ftp-subnet-nsg"
  resource_group_name = azurerm_resource_group.project.name
  location   =    var.location

  security_rule  {
  name      =   "ftp"
  priority   =  120
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "20-21"
  destination_address_prefix = "*"
  description = "Allowing the traffic on port 21 for FTP connections"
  }

  security_rule  {
    access = "Allow"
    description = "Allow traffic on port 22 for remote administration"
    destination_address_prefix = "*"
    destination_port_range = "22"
    direction = "Inbound"
    name = "ssh"
    priority = 110
    protocol = "Tcp"
    source_address_prefix = "*"
    source_port_range = "*"
  }
  security_rule  {
  name         =   "Data-ftp"
  priority   =  200
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "10000-10005"
  destination_address_prefix = "*"
  description = "Allowing the traffic on the ports 10000-10005  for FTP Data transfer"
  }

  tags = {
    "Projet" = "FTP"
    "Resources" = "FTP Servers"
  }
}

resource "azurerm_network_security_group" "eve" {
  name       =    "eve-nsg"
  resource_group_name = azurerm_resource_group.eve_project.name
  location   =    var.location

  security_rule {
    access = "Allow"
    description = "Allow traffic on port 22 for remote administration"
    destination_address_prefix = "*"
    destination_port_range = "22"
    direction = "Inbound"
    name = "ssh"
    priority = 110
    protocol = "Tcp"
    source_address_prefix = "*"
    source_port_range = "*"
  } 

  security_rule  {
  name         =   "http"
  priority   =  120
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "80"
  destination_address_prefix = "*"
  description = "Allowing the traffic on port 80 for HTTP connections"
    }


  tags = {
    "Projet" = "Eve-ng"
    "Resources" = "eve-ng Host"
  }
}

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

####### VNET Creation ######

resource "azurerm_virtual_network" "ftpnet" {
  name = "ftp_vnet"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name
  address_space = [var.VnetAddressSpace]
 
  tags = {
    "Project" = "FTP"
  }
}

resource "azurerm_subnet" "slb" {
  name = var.SubnetName[0]
  address_prefixes = [var.SubnetAddressPrefix[0] ]
  virtual_network_name = azurerm_virtual_network.ftpnet.name  
  resource_group_name = azurerm_resource_group.project.name 
}

resource "azurerm_subnet" "ftp" {
  name = var.SubnetName[1]
  address_prefixes = [var.SubnetAddressPrefix[1] ]
  virtual_network_name = azurerm_virtual_network.ftpnet.name  
  resource_group_name = azurerm_resource_group.project.name 
}

resource "azurerm_subnet" "bastion" {
  name = var.SubnetName[2]
  address_prefixes = [var.SubnetAddressPrefix[2] ]
  virtual_network_name = azurerm_virtual_network.ftpnet.name  
  resource_group_name = azurerm_resource_group.project.name 
}

resource "azurerm_subnet" "eve" {
  name = var.SubnetName[3]
  address_prefixes = [var.SubnetAddressPrefix[3] ]
  virtual_network_name = azurerm_virtual_network.ftpnet.name  
  resource_group_name = azurerm_resource_group.project.name 
}
######### NSG Associations ##############

resource "azurerm_subnet_network_security_group_association" "ftp" {
  network_security_group_id = azurerm_network_security_group.ftp.id
  subnet_id = azurerm_subnet.ftp.id
}

resource "azurerm_subnet_network_security_group_association" "slb" {
  network_security_group_id = azurerm_network_security_group.ftp.id 
  subnet_id = azurerm_subnet.slb.id
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  network_security_group_id = azurerm_network_security_group.bastion.id
  subnet_id = azurerm_subnet.bastion.id
}

resource "azurerm_subnet_network_security_group_association" "eve" {
  network_security_group_id = azurerm_network_security_group.eve.id
  subnet_id = azurerm_subnet.eve.id
}

############## Creation of Public IPs ##############

resource "azurerm_public_ip" "bastion_ip" {
  name = "Bastion-PIP"
  allocation_method = "Static"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name
  sku = "Standard"
  

  tags = {
    "Project" = "FTP"
    "Resources"  = "Bastion Host"
  }
}

resource "azurerm_public_ip" "slb_ip" {
  name = "slb-PIP"
  allocation_method = "Static"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name
  sku = "Standard"
  

  tags = {
    "Project" = "FTP"
    "Resources" = "SLB"
  }
}

resource "azurerm_public_ip" "eve_ip" {
  name = "eve-PIP"
  allocation_method = "Static"
  location = var.location
  resource_group_name = azurerm_resource_group.eve_project.name 
  sku = "Basic"
  domain_name_label = local.eveDnsLabel
    
  tags = {
    "Project" = "Eve-ng"
  }
}

################ Network Interfaces ###############

resource "azurerm_network_interface" "ftp_nic" {
  count = local.instance_count
  name = "ftpnic-0${count.index}"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name 
  enable_ip_forwarding = false
  
  ip_configuration {
    name = "ftpipconfig${count.index}"
    subnet_id = azurerm_subnet.ftp.id
    private_ip_address_allocation = "dynamic" 
  }

  tags = {
    "Project" = "FTP"
    "Resources" = "FTP servers IP Config"
    "Deployment" = "Terraform"
  }
}

resource "azurerm_network_interface" "eve_nic" {
  name = "vmnic-${var.evesrvName}"
  location = var.location
  resource_group_name = azurerm_resource_group.eve_project.name 
  enable_ip_forwarding = false
    
  ip_configuration {
    name = "${var.evesrvName}-ipconfig"
    subnet_id = azurerm_subnet.eve.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.eve_ip.id
  }

  tags = {
    "Project" = "Eve-ng"
    "Resources" = "Eve-ng Server"
    "Deployment" = "Terraform"
  }
}

######### Bastion Host ############

resource "azurerm_bastion_host" "Bastion" {
  name = "ftp-bastion"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name
    
  ip_configuration {
    name = "Bastion_ipconfig"
    subnet_id = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id 
  }

  tags = {
    "Project" = "FTP"
    "Resources" = "Bastion"
    }
}

################ AS ####################

resource "azurerm_availability_set" "slb_as" {
  name = "ftp-as"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name
  platform_fault_domain_count = 2
  platform_update_domain_count = 2
  managed = true

  tags = {
    "Project" = "FTP"
    "Resources" = "FTP AS"
  }
}

############ Managed Disks for VMs ############

resource "azurerm_managed_disk" "ftpDisk" {
  count = local.instance_count
  name = "ftpDisk_${count.index}"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 40

  tags = {
    "Project" = "FTP"
    "Resources" = "FTP VM Disk"
  }  
}

resource "azurerm_managed_disk" "eveDisk" {
  name = "eveDisk"
  location = var.location
  resource_group_name = azurerm_resource_group.eve_project.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 80
  image_reference_id = "value"


  tags = {
    "Project" = "Eve-ng"
    "Resources" = "Eve VM Disk"
  }
}

############### SLB ##############

resource "azurerm_lb" "ftpSLB" {
  name = "ftp-slb"
  sku = "Standard"
  location = var.location
  resource_group_name = azurerm_resource_group.project.name

  frontend_ip_configuration {
    name = "ftpSLB_ipconfig"
    public_ip_address_id = azurerm_public_ip.slb_ip.id
  }

  tags = {
    "Project" = "FTP"
    "Resources" = "FTP SLB"
  }
}

resource "azurerm_lb_backend_address_pool" "ftpPool" {
  name = "ftp_Pool"
  loadbalancer_id = azurerm_lb.ftpSLB.id

  depends_on = [azurerm_lb.ftpSLB]
}

resource "azurerm_network_interface_backend_address_pool_association" "ftpnicAssoc" {
  count = local.instance_count
  network_interface_id = azurerm_network_interface.ftp_nic[count.index].id
  ip_configuration_name =  "ftpipconfig${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ftpPool.id
}

resource "azurerm_lb_rule" "ftpConnection" {
  name = "ftp_Connection"
  resource_group_name = azurerm_lb.ftpSLB.resource_group_name
  loadbalancer_id = azurerm_lb.ftpSLB.id
  frontend_ip_configuration_name = "ftpSLB_ipconfig"

  protocol = "Tcp"
  frontend_port = 21
  backend_port = 21
  backend_address_pool_id = azurerm_lb_backend_address_pool.ftpPool.id
}

resource "azurerm_lb_rule" "ftpData" {
  count = 6
  name = "DataRule_${count.index}"
  resource_group_name = azurerm_lb.ftpSLB.resource_group_name
  loadbalancer_id = azurerm_lb.ftpSLB.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.ftpPool.id
  frontend_ip_configuration_name = "ftpSLB_ipconfig"

  protocol = "Tcp"
  frontend_port = "1000${count.index}"
  backend_port = "1000${count.index}"
  probe_id = azurerm_lb_probe.ftpProbe.id

  depends_on = [azurerm_lb_probe.ftpProbe]
}

resource "azurerm_lb_probe" "ftpProbe" {
  name = "ftpSLB_Probe"
  resource_group_name = azurerm_lb.ftpSLB.resource_group_name
  port = 22
  protocol = "Tcp"
  loadbalancer_id = azurerm_lb.ftpSLB.id
  interval_in_seconds = 10

  depends_on = [azurerm_lb.ftpSLB]
}

################### VMs ############################

resource "azurerm_linux_virtual_machine" "eve" {
  name = var.evesrvName
  location = var.location
  resource_group_name = azurerm_resource_group.eve_project.name
  size = var.eveVMSize
  network_interface_ids = [ azurerm_network_interface.eve_nic.id ]
  disable_password_authentication = false
  admin_username = var.username
  admin_password = var.password
  
  source_image_reference {
    publisher = "canonical"
    offer = local.vmOffer
    sku = local.eveSKU
    version = "Gen1"   
  }

  os_disk {
    name = "eveOSDisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 120
  }
  
  admin_ssh_key { 
    username = var.username
    public_key = file("/home/tchimwa/.ssh/id_rsa.pub")
  }

  connection {
    host = join("", [local.eveDnsLabel, ".",var.location, ".", "cloudapp.azure.com"])         
    type = "ssh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade",
      "sudo apt install vsftpd"

    ]
  }

  tags = {
    "Project" = "Eve-ng"
    "Resources" = "Eve VM"
  }
}

resource "azurerm_linux_virtual_machine" "ftp" {
  count = local.instance_count
  name = "ftpsrv0${count.index}"
  location = var.location
  availability_set_id = azurerm_availability_set.slb_as.id
  resource_group_name = azurerm_resource_group.project.name
  admin_username = var.username
  admin_password = var.password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.ftp_nic[count.index].id]
  size = var.VMSize

  source_image_reference {
    publisher = "canonical"
    offer = local.vmOffer
    sku = local.ftpSKU
    version = "Latest"   
  }

  os_disk {
    name = "eveOSDisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 40
  }
  
  tags = {
    "Project" = "FTP"
    "Resources" = "FTP Server"
  }
}
