######################################################
# This file defines which value are sent to output
######################################################

######################################################
# Resource group info Output

output "ResourceGroupName" {

    value = "${module.RG_LimitedMgmt.Name}"
}

output "ResourceGroupId" {

    value = "${module.RG_LimitedMgmt.Id}"
}

######################################################
# VNet Output info

output "VNetName" {

    value = "${data.azurerm_virtual_network.SourceVNet.name}"
}

output "VNetId" {

    value = "${data.azurerm_virtual_network.SourceVNet.id}"
}

output "VNetSubnets" {

    value = "${data.azurerm_virtual_network.SourceVNet.subnets}"
}

output "VNetSubnet1" {

    value = "${element(data.azurerm_virtual_network.SourceVNet.subnets,0)}"
}

output "VNetSubnet2" {

    value = "${element(data.azurerm_virtual_network.SourceVNet.subnets,1)}"
}

output "SubnetBEId" {

    value = "${data.azurerm_subnet.BE_Subnet.id}"
}


######################################################
# VM Output Info



