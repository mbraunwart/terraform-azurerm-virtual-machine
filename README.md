<!-- BEGIN_TF_DOCS -->
<!-- TOC -->
<!-- /TOC -->

# Azure Enterprise Virtual Machine Module

This Terraform module provides an enterprise-ready framework for deploying and managing Azure Virtual Machines with built-in monitoring, diagnostics, and security features. It supports both Windows and Linux workloads while maintaining consistent deployment patterns and operational excellence.

## Purpose

The module simplifies VM provisioning by incorporating enterprise best practices, security controls, and monitoring capabilities. It reduces the complexity of managing different OS types and ensures consistent deployment patterns across your Azure environment.

## Key Capabilities

- **Multi-OS Support**  
  Deploy either Windows or Linux VMs using the same module with consistent configuration patterns.

- **Enhanced Monitoring**  
  Built-in Azure Monitor Agent integration with configurable diagnostic settings for comprehensive monitoring.

- **Security Features**  
  System-assigned managed identities, secure password handling, and support for marketplace images with plans.

- **Network Integration**  
  Flexible networking options including private and public IP support.

## Implementation Details

The module implements a secure-by-default approach with managed identities and built-in monitoring. It handles the complexity of marketplace image deployments, including automatic acceptance of terms and conditions. The implementation supports both password-based authentication with secure password handling.

### Architecture Overview

Each VM deployment includes:
- Network Interface with configurable IP settings
- OS Disk with customizable size and type
- System-assigned managed identity
- Azure Monitor Agent (optional)
- Diagnostic settings integration
- Boot diagnostics

### Best Practices

- Use strong passwords and consider rotating them regularly
- Enable Azure Monitor Agent for comprehensive monitoring
- Configure appropriate diagnostic settings based on operational requirements
- Tag resources appropriately for cost allocation and management
- Regular OS and security patches through Azure Update Management

## Diagnostic Settings

The module supports comprehensive monitoring through:
- Azure Monitor Agent for both Windows and Linux
- Performance counters for CPU, memory, disk, and network metrics
- Windows Event logs or Linux Syslog collection
- Integration with Log Analytics workspace

## Known Limitations

- OS disk encryption at rest uses platform-managed keys
- Custom script extensions are not directly supported
- Only password authentication is supported (no SSH keys)
- Single network interface per VM

## Usage Example

```hcl
# Windows Server Example
module "windows_vm" {
  source = "github.com/your-org/terraform-azurerm-virtual-machine"

  resource_group_name = "rg-demo-windows"
  location            = "eastus2"
  subnet_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-apps"

  vm_config = {
    name           = "vmwin01"
    size           = "Standard_D2s_v3"
    admin_user     = "azureadmin"
    admin_password = "MySecureP@ssw0rd!"
    os_type       = "Windows"
  }

  image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk = {
    storage_account_type = "Premium_LRS"
    size_gb             = 256
  }

  monitoring = {
    azure_monitor_agent_enabled = true
    log_analytics = {
      resource_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-prod"
      workspace_name     = "log-prod"
      storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.Storage/storageAccounts/stdiagprod"
    }
  }

  tags = {
    Environment = "Production"
    Department  = "IT"
    CostCenter  = "12345"
    Application = "Core Infrastructure"
  }
}

# Linux Example with Marketplace Image
module "linux_vm" {
  source = "github.com/your-org/terraform-azurerm-virtual-machine"

  resource_group_name = "rg-demo-linux"
  location            = "eastus2"
  subnet_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-apps"

  vm_config = {
    name           = "vmlin01"
    size           = "Standard_D2s_v3"
    admin_user     = "azureadmin"
    admin_password = "MySecureP@ssw0rd!"
    os_type       = "Linux"
  }

  image_reference = {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-lvm-gen2"
    version   = "latest"
    plan = {
      name      = "8-lvm-gen2"
      product   = "rhel-byos"
      publisher = "redhat"
    }
  }

  os_disk = {
    storage_account_type = "Premium_LRS"
    size_gb             = 128
  }

  monitoring = {
    azure_monitor_agent_enabled = true
    log_analytics = {
      resource_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-prod"
      workspace_name     = "log-prod"
      storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.Storage/storageAccounts/stdiagprod"
    }
  }

  tags = {
    Environment = "Production"
    Department  = "DevOps"
    CostCenter  = "12345"
    Application = "Web Services"
  }
}
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement_terraform) (>=1.5.0, <2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) (>= 4.12.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) (>= 4.12.0)

- <a name="provider_null"></a> [null](#provider_null)

## Resources

The following resources are used by this module:

- [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) (resource)
- [azurerm_monitor_data_collection_rule.linux-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) (resource)
- [azurerm_monitor_data_collection_rule.windows-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) (resource)
- [azurerm_monitor_data_collection_rule_association.linux-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) (resource)
- [azurerm_monitor_data_collection_rule_association.windows-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) (resource)
- [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_virtual_machine_extension.linux-ama](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.windows-ama](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) (resource)
- [null_resource.accept_marketplace_terms](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_image_reference"></a> [image_reference](#input_image_reference)

Description: Virtual machine image reference configuration including:
  `publisher` - The publisher of the image used to create the VM
  `offer`     - The offer of the image used to create the VM
  `sku`       - The SKU of the image used to create the VM
  `version`   - The version of the image used to create the VM
  `plan`      - (Optional) The marketplace image plan configuration containing:
    `name`      - The plan name
    `product`   - The product name
    `publisher` - The publisher ID

Type:

```hcl
object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
    plan = optional(object({
      name      = string
      product   = string
      publisher = string
    }))
  })
```

### <a name="input_location"></a> [location](#input_location)

Description: The Azure region where the VM will be deployed.

Type: `string`

### <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)

Description: The name of the resource group in which to create the VM.

Type: `string`

### <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id)

Description: The ID of the subnet where the VM will be placed.

Type: `string`

### <a name="input_vm_config"></a> [vm_config](#input_vm_config)

Description: Virtual machine configuration settings including:
  `name`           - The name of the virtual machine
  `size`           - The SKU size of the virtual machine (e.g., Standard_DS2_v2)
  `admin_user`     - The administrative username for the VM
  `admin_password` - The administrative password for the VM
  `os_type`        - (Optional) The OS type, either "Windows" or "Linux". Defaults to "Windows"
  `public_ip_id`   - (Optional) The ID of a public IP to associate with the VM

Type:

```hcl
object({
    name           = string
    size           = string
    admin_user     = string
    admin_password = string
    os_type        = optional(string, "Windows")
    public_ip_id   = optional(string)
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_is_windows"></a> [is_windows](#input_is_windows)

Description: Boolean flag to determine if running on Windows

Type: `bool`

Default: `true`

### <a name="input_monitoring"></a> [monitoring](#input_monitoring)

Description: Monitoring configuration settings including:
  `azure_monitor_agent_enabled` - (Optional) Enable Azure Monitor Agent. Defaults to false
  `log_analytics`              - (Optional) Log Analytics configuration containing:
    `resource_id`        - The Log Analytics workspace resource ID
    `workspace_name`     - The Log Analytics workspace name

Type:

```hcl
object({
    azure_monitor_agent_enabled = optional(bool, false)
    log_analytics = optional(object({
      resource_id    = string
      workspace_name = string
    }))
  })
```

Default: `{}`

### <a name="input_os_disk"></a> [os_disk](#input_os_disk)

Description: OS disk configuration including:
  `storage_account_type` - (Optional) The type of storage account for the OS disk. Defaults to "Standard_LRS"
  `size_gb`             - (Optional) The size of the OS disk in GB. Defaults to 128

Type:

```hcl
object({
    storage_account_type = optional(string, "Standard_LRS")
    size_gb              = optional(number, 128)
  })
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input_tags)

Description: A mapping of tags to assign to all resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_nic_id"></a> [nic_id](#output_nic_id)

Description: Network interface ID

### <a name="output_nic_ip_configuration"></a> [nic_ip_configuration](#output_nic_ip_configuration)

Description: Network interface IP configuration

### <a name="output_nic_location"></a> [nic_location](#output_nic_location)

Description: Network interface location

### <a name="output_nic_mac_address"></a> [nic_mac_address](#output_nic_mac_address)

Description: Network interface MAC address

### <a name="output_nic_name"></a> [nic_name](#output_nic_name)

Description: Network interface name

### <a name="output_nic_private_ip_address"></a> [nic_private_ip_address](#output_nic_private_ip_address)

Description: Network interface private IP address

### <a name="output_nic_resource_group_name"></a> [nic_resource_group_name](#output_nic_resource_group_name)

Description: Network interface resource group name

### <a name="output_vm_admin_username"></a> [vm_admin_username](#output_vm_admin_username)

Description: Virtual machine admin username

### <a name="output_vm_computer_name"></a> [vm_computer_name](#output_vm_computer_name)

Description: Virtual machine computer name

### <a name="output_vm_id"></a> [vm_id](#output_vm_id)

Description: Virtual machine ID

### <a name="output_vm_location"></a> [vm_location](#output_vm_location)

Description: Virtual machine location

### <a name="output_vm_name"></a> [vm_name](#output_vm_name)

Description: Virtual machine name

### <a name="output_vm_os_type"></a> [vm_os_type](#output_vm_os_type)

Description: Operating system type of the virtual machine

### <a name="output_vm_private_ip_address"></a> [vm_private_ip_address](#output_vm_private_ip_address)

Description: Virtual machine private IP address

### <a name="output_vm_resource_group_name"></a> [vm_resource_group_name](#output_vm_resource_group_name)

Description: Virtual machine resource group name

### <a name="output_vm_size"></a> [vm_size](#output_vm_size)

Description: Virtual machine size

### <a name="output_vm_source_image_id"></a> [vm_source_image_id](#output_vm_source_image_id)

Description: Virtual machine source image ID
<!-- END_TF_DOCS -->