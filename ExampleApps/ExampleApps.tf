######################################################
# This file deploys a Bastion VM in an existing
# BE Subnet
######################################################



data "azurerm_resource_group" "SourceRG" {

    name = "${var.SourceRGName}"

}

data "azurerm_virtual_network" "SourceVNetName" {

    #It is possible to retake the same input value as for the "parent" template
    #name                    = "${var.EnvironmentTag}_VNet"
    #OR since we know the name of the deployed VNet, we could just add it in the variable file
    name                    = "${var.SourcevNetName}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRG.name}"
}

data "azurerm_subnet" "FE_Subnet" {

    #Again, it is possible to quite elegantly use a vnet data source and the output list of the associated subnet
    #name                    = "${element(data.azurerm_virtual_network.SourceVNet.subnets,1)}"
    #Or, again, since we do know the name of the subnet, just use the name from a list in the variable file
    name                    = "${element(var.SourceSubnetNameList,0)}"    
    virtual_network_name    = "${data.azurerm_virtual_network.SourceVNet.name}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRG.name}"
}

data "azurerm_subnet" "BE_Subnet" {

    name                    = "${element(var.SourceSubnetNameList,1)}"
    virtual_network_name    = "${data.azurerm_virtual_network.SourceVNet.name}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRG.name}"
}