######################################################
# This file defines which value are sent to output
######################################################

######################################################
# Resource group info Output

output "ResourceGroupName" {

    value = "${module.RG_ExampleApps.Name}"
}

output "ResourceGroupId" {

    value = "${module.RG_ExampleApps.Id}"
}

output "InfraResourceGroupName" {

    value = "${data.azurerm_resource_group.SourceRGName.name}"
}

output "InfraResourceGroupId" {

    value = "${data.azurerm_resource_group.SourceRGName.id}"
}


output "InfraResourceGroupTags" {

    value = "${data.azurerm_resource_group.SourceRGName.tags}"
}


output "InfraResourceGroupLocation" {

    value = "${data.azurerm_resource_group.SourceRGName.location}"
}


######################################################
# VNet Output info

output "VNetName" {

    value = "${data.azurerm_virtual_network.SourceVNetName.name}"
}

output "VNetId" {

    value = "${data.azurerm_virtual_network.SourceVNetName.id}"
}

output "VNetSubnets" {

    value = "${data.azurerm_virtual_network.SourceVNetName.subnets}"
}

output "VNetDNS" {

    value = "${data.azurerm_virtual_network.SourceVNetName.dns_servers}"
}

output "VNetSubnet1" {

    value = "${element(data.azurerm_virtual_network.SourceVNetName.subnets,0)}"
}

output "VNetSubnet2" {

    value = "${element(data.azurerm_virtual_network.SourceVNetName.subnets,1)}"
}

output "SubnetBEId" {

    value = "${data.azurerm_subnet.BE_Subnet.id}"
}


output "SubnetFEId" {

    value = "${data.azurerm_subnet.FE_Subnet.id}"
}

######################################################
# VM Output Info



