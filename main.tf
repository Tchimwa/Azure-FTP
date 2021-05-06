provider "azurerm" {
  features {}
}

### Creation of the Resource Group ###

resource "azurerm_resource_group" "project" {
    name     = "project-ftp-rg"
    location = var.location

    tags = {
      "Deployment"  = "Terraform"
      "Project"          =  "FTP"
    }
}
resource "azurerm_resource_group" "eve_project" {
    name     = "eve-rg"
    location = var.location

    tags = {
      "Deployment"  = "Terraform"
      "Project"          =  "Eve-ng"
    }
}
