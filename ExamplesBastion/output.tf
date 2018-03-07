######################################################
# This file defines which value are sent to output
######################################################

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
# Target Resource group info Output containing VMs

output "RG_ExampleBastionName" {

    value = "${module.RG_ExampleBastion.Name}"
}

output "RG_ExampleBastiontId" {

    value = "${module.RG_ExampleBastion.Id}"
}


######################################################
# Source Resource group info Output, containing VNet

output "RGVNetName" {

    value = "${data.azurerm_resource_group.SourceRGName.name}"
}

output "RGVNetId" {

    value = "${data.azurerm_resource_group.SourceRGName.id}"
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

output "VNetSubnet1" {

    value = "${element(data.azurerm_virtual_network.SourceVNetName.subnets,0)}"
}

output "VNetSubnet2" {

    value = "${element(data.azurerm_virtual_network.SourceVNetName.subnets,1)}"
}

output "SubnetBastionId" {

    value = "${data.azurerm_subnet.Bastion_Subnet.id}"
}



######################################################
# VM Output Info



