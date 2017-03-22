# Configure the Microsoft Azure Provider
provider "azurerm" { }

resource "azurerm_resource_group" "cncf" {
  name     = "${ var.name }"
  location = "${ var.location }"
}

resource "azurerm_storage_account" "cncf" {
  # FIXME: storage_account name must be globally unique
  name                = "${ var.name }cncfdemo"
  resource_group_name = "${ var.name }"
  location            = "${ var.location }"
  account_type        = "Standard_LRS"
}

resource "azurerm_storage_container" "cncf" {
  name                  = "${ var.name }"
  resource_group_name   = "${ var.name }"
  storage_account_name  = "${ azurerm_storage_account.cncf.name }"
  container_access_type = "private"
}

resource "azurerm_availability_set" "cncf" {
  name                = "${ var.name }"
  resource_group_name = "${ var.name }"
  location            = "${ var.location }"

}

