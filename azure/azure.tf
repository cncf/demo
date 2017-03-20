# Configure the Microsoft Azure Provider
provider "azurerm" { }

resource "azurerm_resource_group" "main" {
  name     = "${ var.azure["resource-group"] }"
  location = "${ var.azure["location"] }"
  }

resource "azurerm_storage_account" "test" {
  name                = "accsa1231234"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  account_type        = "Standard_LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  resource_group_name = "${ azurerm_resource_group.main.name }"
  storage_account_name  = "${ azurerm_storage_account.test.name }"
  container_access_type = "private"
}

resource "azurerm_availability_set" "test" {
  name = "acceptanceTestAvailabilitySet1"
  location = "${ var.azure["location"] }"
  resource_group_name = "${azurerm_resource_group.main.name}"

}

