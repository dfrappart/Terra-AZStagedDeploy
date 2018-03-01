######################################################
# This file deploys a Bastion VM in an existing
# BE Subnet
######################################################



data "azurerm_resource_group" "SourceRG" {

    name = "${var.RGName}"

}

data "azurerm_virtual_network" "SourceVNet" {

    name                    = "${var.EnvironmentTag}_VNet"
    resource_group_name     = "${data.azurerm_resource_group.SourceRG.name}"
}

data "azurerm_subnet" "BE_Subnet" {

    name                    = "${element(data.azurerm_virtual_network.SourceVNet.subnets,1)}"
    virtual_network_name    = "${data.azurerm_virtual_network.SourceVNet.name}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRG.name}"
}