######################################################
# This file deploys the NSG Rules applied to Subnet
######################################################

######################################################################
# NSG Front End

#Rule creation allow HTTP to Bastion

module "AllowHTTPFromInternettoFEIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_FE_Subnet.Name}"
    NSGRuleName = "AllowHTTPFromInternettoFEIn"
    NSGRulePriority = 101
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "Tcp"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = 80
    NSGRuleSourceAddressPrefix = "Internet"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 0)}"
}

#Rule creation allow HTTPS to Bastion

module "AllowHTTPSFromInternettoFEIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_FE_Subnet.Name}"
    NSGRuleName = "AllowHTTPSFromInternettoFEIn"
    NSGRulePriority = 102
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "Tcp"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = 443
    NSGRuleSourceAddressPrefix = "Internet"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 0)}"
}

######################################################################
# NSG Back End




######################################################################
# NSG Bastion

#Rule creation allow SSH to Bastion

module "AllowSSHFromInternetBastionIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_Bastion_Subnet.Name}"
    NSGRuleName = "AllowSSHFromInternetBastionIn"
    NSGRulePriority = 101
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "Tcp"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = 22
    NSGRuleSourceAddressPrefix = "Internet"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 2)}"
}


#Rule creation allow RDP to Bastion

module "AllowRDPFromInternetBastionIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_Bastion_Subnet.Name}"
    NSGRuleName = "AllowRDPFromInternetBastionIn"
    NSGRulePriority = 102
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "Tcp"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = 3389
    NSGRuleSourceAddressPrefix = "Internet"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 2)}"
}