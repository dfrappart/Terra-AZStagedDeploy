######################################################
# This file deploys a Bastion VM in an existing
# Bastion Subnet
######################################################

######################################################################
# Access to Azure
######################################################################


# Configure the Microsoft Azure Provider with Azure provider variable defined in AzureDFProvider.tf

provider "azurerm" {

    subscription_id = "${var.AzureSubscriptionID}"
    client_id       = "${var.AzureClientID}"
    client_secret   = "${var.AzureClientSecret}"
    tenant_id       = "${var.AzureTenantID}"
}


######################################################################
# Source data used in the template
######################################################################


data "azurerm_resource_group" "SourceRGName" {

    name = "${var.SourceRGName}"

}

data "azurerm_virtual_network" "SourceVNetName" {

    #It is possible to retake the same input value as for the "parent" template
    #name                    = "${var.EnvironmentTag}_VNet"
    #OR since we know the name of the deployed VNet, we could just add it in the variable file
    name                    = "${var.SourcevNetName}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRGName.name}"
}

data "azurerm_subnet" "FE_Subnet" {

    #Again, it is possible to quite elegantly use a vnet data source and the output list of the associated subnet
    #name                    = "${element(data.azurerm_virtual_network.SourcevNetName.subnets,1)}"
    #Or, again, since we do know the name of the subnet, just use the name from a list in the variable file
    name                    = "${element(var.SourceSubnetNameList,0)}"    
    virtual_network_name    = "${data.azurerm_virtual_network.SourceVNetName.name}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRGName.name}"
}

data "azurerm_subnet" "BE_Subnet" {

    name                    = "${element(var.SourceSubnetNameList,1)}"
    virtual_network_name    = "${data.azurerm_virtual_network.SourceVNetName.name}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRGName.name}"
}

data "azurerm_subnet" "Bastion_Subnet" {

    name                    = "${element(var.SourceSubnetNameList,2)}"
    virtual_network_name    = "${data.azurerm_virtual_network.SourceVNetName.name}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRGName.name}"
}

data "azurerm_storage_account" "SourceSTOADiagLog" {
  name                 = "stoadiaglogstandardlrs"
  resource_group_name  = "${data.azurerm_resource_group.SourceRGName.name}"
}
######################################################################
# Azure Resources creation
######################################################################

# Creating the RG_ExampleBastion


module "RG_ExampleBastion" {

    #Module Location
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//01 ResourceGroup/"
    
    #Module variable
    RGName                  = "${var.NewRGName}"
    RGLocation              = "${var.AzureRegion}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"
}


# Creating the AS

#Availability set creation


module "AS_ExampleBastion" {

    #Module source

    #source = "./Modules/13 AvailabilitySet"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//13 AvailabilitySet"


    #Module variables
    ASName                  = "AS_ExampleBastion"
    RGName                  = "${module.RG_ExampleBastion.Name}"
    ASLocation              = "${var.AzureRegion}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"

}

# Creating the DataDisk

module "DataDisks_ExampleBastion" {

    #Module source

    #source = "./Modules/06 ManagedDiskswithcount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//06 ManagedDiskswithcount"


    #Module variables

    Manageddiskcount    = "3"
    ManageddiskName     = "DataDisk_ExampleBastion"
    RGName              = "${module.RG_ExampleBastion.Name}"
    ManagedDiskLocation = "${var.AzureRegion}"
    StorageAccountType  = "${lookup(var.Manageddiskstoragetier, 0)}"
    CreateOption        = "Empty"
    DiskSizeInGB        = "63"
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

# Creating the Public IPs

module "ExampleBastionPublicIP" {

    #Module source
    #source = "./Modules/10 PublicIP"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//10 PublicIP"

    #Module variables
    PublicIPCount           = "3"
    PublicIPName            = "bastionpip"
    PublicIPLocation        = "${var.AzureRegion}"
    RGName                  = "${module.RG_ExampleBastion.Name}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"


}

# Creating the NIC



module "NICs_ExampleBastion" {

    #module source

    #source = "./Modules/12 NICwithPIPWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//12 NICwithPIPWithCount"

    #Module variables

    NICCount            = "3"
    NICName             = "NIC_ExampleBastion"
    NICLocation         = "${var.AzureRegion}"
    RGName              = "${module.RG_ExampleBastion.Name}"
    SubnetId            = "${data.azurerm_subnet.Bastion_Subnet.id}"
    PublicIPId          = ["${module.ExampleBastionPublicIP.Ids}"]
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

# Creating the VM

module "VMs_ExampleBastion" {

    #module source

    #source = "./Modules/14 LinuxVMWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//14 LinuxVMWithCount"


    #Module variables

    VMCount                     = "3"
    VMName                      = "ExampleBastion"
    VMLocation                  = "${var.AzureRegion}"
    VMRG                        = "${module.RG_ExampleBastion.Name}"
    VMNICid                     = ["${module.NICs_ExampleBastion.Ids}"]
    VMSize                      = "${lookup(var.VMSize, 0)}"
    ASID                        = "${module.AS_ExampleBastion.Id}"
    VMStorageTier               = "${lookup(var.Manageddiskstoragetier, 0)}"
    VMAdminName                 = "${var.VMAdminName}"
    VMAdminPassword             = "${var.VMAdminPassword}"
    DataDiskId                  = ["${module.DataDisks_ExampleBastion.Ids}"]
    DataDiskName                = ["${module.DataDisks_ExampleBastion.Names}"]
    DataDiskSize                = ["${module.DataDisks_ExampleBastion.Sizes}"]
    VMPublisherName             = "${lookup(var.PublisherName, 4)}"
    VMOffer                     = "${lookup(var.Offer, 4)}"
    VMsku                       = "${lookup(var.sku, 4)}"
    DiagnosticDiskURI           = "${data.azurerm_storage_account.SourceSTOADiagLog.primary_blob_endpoint}"
    PublicSSHKey                = "${var.AzurePublicSSHKey}"
    EnvironmentTag              = "${var.EnvironmentTag}"
    EnvironmentUsageTag         = "${var.EnvironmentUsageTag}"

}

# Creating the Network Watcher Agent

module "NetworkWatcherAgentForBastion" {

    #Module Location
    #source = "./Modules/20 LinuxNetworkWatcherAgent"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//20 LinuxNetworkWatcherAgent"


    #Module variables
    AgentCount              = "3"
    AgentName               = "NetworkWatcherAgentForBastion"
    AgentLocation           = "${var.AzureRegion}"
    AgentRG                 = "${module.RG_ExampleBastion.Name}"
    VMName                  = ["${module.VMs_ExampleBastion.Name}"]
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"
}


#Creating Storage Account for files exchange

module "FilesExchangeStorageAccount" {

    #Module location
    #source = "./Modules/03 StorageAccountGP"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//03 StorageAccountGP/"

    #Module variable
    StorageAccountName                  = "Infra"
    RGName                              = "${module.RG_ExampleBastion.Name}"
    StorageAccountLocation              = "${var.AzureRegion}"
    StorageAccountTier                  = "${lookup(var.storageaccounttier, 0)}"
    StorageReplicationType              = "${lookup(var.storagereplicationtype, 0)}"
    EnvironmentTag                      = "${var.EnvironmentTag}"
    EnvironmentUsageTag                 = "${var.EnvironmentUsageTag}"


}

#Creating Storage Share

module "InfraFileShare" {

    #Module location
    #source = "./Modules/05 StorageAccountShare"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//05 StorageAccountShare"
    
    #Module variable
    ShareName           = "infrafileshare"
    RGName              = "${module.RG_ExampleBastion.Name}"
    StorageAccountName  = "${module.FilesExchangeStorageAccount.Name}"
    Quota               = "0"


}