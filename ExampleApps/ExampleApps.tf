######################################################
# This file deploys a Bastion VM in an existing
# BE Subnet
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

    
    name                    = "${var.SourcevNetName}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRGName.name}"
}

data "azurerm_subnet" "FE_Subnet" {

    
    name                    = "${element(var.SourceSubnetNameList,0)}"    
    virtual_network_name    = "${data.azurerm_virtual_network.SourceVNetName.name}"
    resource_group_name     = "${data.azurerm_resource_group.SourceRGName.name}"
}

data "azurerm_subnet" "BE_Subnet" {

    name                    = "${element(var.SourceSubnetNameList,1)}"
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

# Creating the RG_ExampleApps


module "RG_ExampleApps" {

    #Module Location
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//01 ResourceGroup/"
    
    #Module variable
    RGName                  = "${var.NewRGName}"
    RGLocation              = "${var.AzureRegion}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"
}



#Availability set creation


module "AS_ExampleFE" {

    #Module source

    #source = "./Modules/13 AvailabilitySet"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//13 AvailabilitySet"


    #Module variables
    ASName                  = "AS_ExampleFE"
    RGName                  = "${module.RG_ExampleApps.Name}"
    ASLocation              = "${var.AzureRegion}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"

}

# Creating the DataDisk

module "DataDisks_ExampleFE" {

    #Module source

    #source = "./Modules/06 ManagedDiskswithcount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//06 ManagedDiskswithcount"


    #Module variables

    Manageddiskcount    = "2"
    ManageddiskName     = "DataDisk_ExampleFE"
    RGName              = "${module.RG_ExampleApps.Name}"
    ManagedDiskLocation = "${var.AzureRegion}"
    StorageAccountType  = "${lookup(var.Manageddiskstoragetier, 0)}"
    CreateOption        = "Empty"
    DiskSizeInGB        = "63"
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

# Creating the Public IPs

module "ExampleFEPublicIP" {

    #Module source
    #source = "./Modules/10 PublicIP"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//10 PublicIP"

    #Module variables
    PublicIPCount           = "2"
    PublicIPName            = "fepip"
    PublicIPLocation        = "${var.AzureRegion}"
    RGName                  = "${module.RG_ExampleApps.Name}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"


}

# Creating the NIC



module "NICs_ExampleFE" {

    #module source

    #source = "./Modules/12 NICwithPIPWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//12 NICwithPIPWithCount"

    #Module variables

    NICCount            = "2"
    NICName             = "NIC_ExampleFE"
    NICLocation         = "${var.AzureRegion}"
    RGName              = "${module.RG_ExampleApps.Name}"
    SubnetId            = "${data.azurerm_subnet.FE_Subnet.id}"
    PublicIPId          = ["${module.ExampleFEPublicIP.Ids}"]
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

# Creating the VM

module "VMs_ExampleFE" {

    #module source

    #source = "./Modules/14 LinuxVMWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//14 LinuxVMWithCount"


    #Module variables

    VMCount                     = "2"
    VMName                      = "ExampleFE"
    VMLocation                  = "${var.AzureRegion}"
    VMRG                        = "${module.RG_ExampleApps.Name}"
    VMNICid                     = ["${module.NICs_ExampleFE.Ids}"]
    VMSize                      = "${lookup(var.VMSize, 0)}"
    ASID                        = "${module.AS_ExampleFE.Id}"
    VMStorageTier               = "${lookup(var.Manageddiskstoragetier, 0)}"
    VMAdminName                 = "${var.VMAdminName}"
    VMAdminPassword             = "${var.VMAdminPassword}"
    DataDiskId                  = ["${module.DataDisks_ExampleFE.Ids}"]
    DataDiskName                = ["${module.DataDisks_ExampleFE.Names}"]
    DataDiskSize                = ["${module.DataDisks_ExampleFE.Sizes}"]
    VMPublisherName             = "${lookup(var.PublisherName, 4)}"
    VMOffer                     = "${lookup(var.Offer, 4)}"
    VMsku                       = "${lookup(var.sku, 4)}"
    DiagnosticDiskURI           = "${data.azurerm_storage_account.SourceSTOADiagLog.primary_blob_endpoint}"
    PublicSSHKey                = "${var.AzurePublicSSHKey}"
    EnvironmentTag              = "${var.EnvironmentTag}"
    EnvironmentUsageTag         = "${var.EnvironmentUsageTag}"

}

# Creating the Network Watcher Agent

module "NetworkWatcherAgentForFE" {

    #Module Location
    #source = "./Modules/20 LinuxNetworkWatcherAgent"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//20 LinuxNetworkWatcherAgent"


    #Module variables
    AgentCount              = "2"
    AgentName               = "NetworkWatcherAgentForFE"
    AgentLocation           = "${var.AzureRegion}"
    AgentRG                 = "${module.RG_ExampleApps.Name}"
    VMName                  = ["${module.VMs_ExampleFE.Name}"]
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"
}


#Creating Storage Account for files exchange

module "FilesExchangeStorageAccount" {

    #Module location
    #source = "./Modules/03 StorageAccountGP"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//03 StorageAccountGP/"

    #Module variable
    StorageAccountName                  = "Apps"
    RGName                              = "${module.RG_ExampleApps.Name}"
    StorageAccountLocation              = "${var.AzureRegion}"
    StorageAccountTier                  = "${lookup(var.storageaccounttier, 0)}"
    StorageReplicationType              = "${lookup(var.storagereplicationtype, 0)}"
    EnvironmentTag                      = "${var.EnvironmentTag}"
    EnvironmentUsageTag                 = "${var.EnvironmentUsageTag}"


}

#Creating Storage Share

module "AppsFileShare" {

    #Module location
    #source = "./Modules/05 StorageAccountShare"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//05 StorageAccountShare"
    
    #Module variable
    ShareName           = "appsfileshare"
    RGName              = "${module.RG_ExampleApps.Name}"
    StorageAccountName  = "${module.FilesExchangeStorageAccount.Name}"
    Quota               = "0"


}

#Availability set creation


module "AS_ExampleBE" {

    #Module source

    #source = "./Modules/13 AvailabilitySet"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//13 AvailabilitySet"


    #Module variables
    ASName                  = "AS_ExampleBE"
    RGName                  = "${module.RG_ExampleApps.Name}"
    ASLocation              = "${var.AzureRegion}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"

}

# Creating the DataDisk

module "DataDisks_ExampleBE" {

    #Module source

    #source = "./Modules/06 ManagedDiskswithcount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//06 ManagedDiskswithcount"


    #Module variables

    Manageddiskcount    = "2"
    ManageddiskName     = "DataDisk_ExampleBE"
    RGName              = "${module.RG_ExampleApps.Name}"
    ManagedDiskLocation = "${var.AzureRegion}"
    StorageAccountType  = "${lookup(var.Manageddiskstoragetier, 0)}"
    CreateOption        = "Empty"
    DiskSizeInGB        = "63"
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}



# Creating the NIC



module "NICs_ExampleBE" {

    #module source

    #source = "./Modules/12 NICwithPIPWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//09 NICWithoutPIPWithCount"

    #Module variables

    NICcount            = "2"
    NICName             = "NIC_ExampleBE"
    NICLocation         = "${var.AzureRegion}"
    RGName              = "${module.RG_ExampleApps.Name}"
    SubnetId            = "${data.azurerm_subnet.BE_Subnet.id}"
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

# Creating the VM

module "VMs_ExampleBE" {

    #module source

    #source = "./Modules/14 LinuxVMWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//14 LinuxVMWithCount"


    #Module variables

    VMCount                     = "2"
    VMName                      = "ExampleBE"
    VMLocation                  = "${var.AzureRegion}"
    VMRG                        = "${module.RG_ExampleApps.Name}"
    VMNICid                     = ["${module.NICs_ExampleBE.Ids}"]
    VMSize                      = "${lookup(var.VMSize, 0)}"
    ASID                        = "${module.AS_ExampleBE.Id}"
    VMStorageTier               = "${lookup(var.Manageddiskstoragetier, 0)}"
    VMAdminName                 = "${var.VMAdminName}"
    VMAdminPassword             = "${var.VMAdminPassword}"
    DataDiskId                  = ["${module.DataDisks_ExampleBE.Ids}"]
    DataDiskName                = ["${module.DataDisks_ExampleBE.Names}"]
    DataDiskSize                = ["${module.DataDisks_ExampleBE.Sizes}"]
    VMPublisherName             = "${lookup(var.PublisherName, 4)}"
    VMOffer                     = "${lookup(var.Offer, 4)}"
    VMsku                       = "${lookup(var.sku, 4)}"
    DiagnosticDiskURI           = "${data.azurerm_storage_account.SourceSTOADiagLog.primary_blob_endpoint}"
    PublicSSHKey                = "${var.AzurePublicSSHKey}"
    EnvironmentTag              = "${var.EnvironmentTag}"
    EnvironmentUsageTag         = "${var.EnvironmentUsageTag}"

}

# Creating the Network Watcher Agent

module "NetworkWatcherAgentForBE" {

    #Module Location
    #source = "./Modules/20 LinuxNetworkWatcherAgent"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//20 LinuxNetworkWatcherAgent"


    #Module variables
    AgentCount              = "2"
    AgentName               = "NetworkWatcherAgentForBE"
    AgentLocation           = "${var.AzureRegion}"
    AgentRG                 = "${module.RG_ExampleApps.Name}"
    VMName                  = ["${module.VMs_ExampleBE.Name}"]
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"
}