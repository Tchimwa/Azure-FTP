variable "location" {
    description  =  "Location of the resources"
    type             =  string
}

variable "username" {

    description  = "Username for all the VMs"
    type             = string
    default         = "AzureAdmin"
}

variable "password" {
    description =  "Password must meet Azure complexity requirements!"
    type            =  string
    default        =  "Azure123456#" 
}

variable "VMSize" {
    description = "Size of the VMs"
    type            =  string
    default        = "Standard_D2_v2"
}

variable "eveVMSize" {
    description = "Size of the eve-ng server"
    type            =  string
    default        = "Standard_D8_v3"
}

variable "VnetAddressSpace" {
    description  =  "Address Space of the VNET"
    type             =  string
    default         =  "10.23.0.0/16" 
}

variable "SubnetAddressPrefix" {
    description  =  "Address Space for the subnets"
    type             =  list (string)
    default         =  [ "10.23.0.0/24", "10.23.1.0/24",  "10.23.2.0/24", "10.23.3.0/24"]
}

variable "SubnetName" {
    description  =  "Name of different subnets"
    type             =  list (string)
    default         =  ["SLB-sbnet", "FTP-sbnt", "AzureBastionSubnet", "eve-sbnet"] 
}

variable "evesrvName" {
    default = "Eve-ng"
    type = string
}