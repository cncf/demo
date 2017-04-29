# Configure the Microsoft Azure Provider
provider "google" {
  credentials = "${file("gce.json")}"
  project     = "${ var.project }"
  region      = "${ var.region }"
}

provider "dnsimple" {
}

# resource "google_project" "company-env" {
#   project_id         = "${var.ENVIRONMENT}"
#   org_id             = "${var.GCP_ORG_ID}"
#   name               = "${var.ENVIRONMENT}"
#   skip_delete        = "true"
# }

# // APIs to enable for above project
# resource "google_project_services" "company-env" {
#   project            = "${var.ENVIRONMENT}"
#   services           = ["compute_component", "container", "dns.googleapis.com", "sqladmin-json.googleapis.com", "monitoring.googleapis.com", "logging.googleapis.com", "sql-component-json.googleapis.com", "cloudmonitoring.googleapis.com", "storage-component-json.googleapis.com", "iam.googleapis.com"]
# }

# resource "azurerm_resource_group" "cncf" {
#   name     = "${ var.name }"
#   location = "${ var.location }"
# }

# resource "azurerm_storage_account" "cncf" {
#   # * azurerm_storage_account.cncf: name can only consist of lowercase letters
#   # and numbers, and must be between 3 and 24 characters long FIXME:
#   # storage_account name must be globally unique
#   name                = "${ var.name }cncfdemo"
#   resource_group_name = "${ var.name }"
#   location            = "${ var.location }"
#   account_type        = "Standard_LRS"
# }

# resource "azurerm_storage_container" "cncf" {
#   name                  = "${ var.name }"
#   resource_group_name   = "${ var.name }"
#   storage_account_name  = "${ azurerm_storage_account.cncf.name }"
#   container_access_type = "private"
# }

# resource "azurerm_availability_set" "cncf" {
#   name                = "${ var.name }"
#   resource_group_name = "${ var.name }"
#   location            = "${ var.location }"

# }

