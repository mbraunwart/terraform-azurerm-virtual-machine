variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the VM."
}

variable "location" {
  type        = string
  description = "The Azure region where the VM will be deployed."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the VM will be placed."
}

variable "private_ip_address_allocation" {
  type        = string
  description = "The allocation method for the private IP address."
  default     = "Dynamic"

  validation {
    condition     = can(regex("^(Dynamic|Static)$", var.private_ip_address_allocation))
    error_message = "Private IP address allocation must be either 'Dynamic' or 'Static'."
  }
}

variable "vm_config" {
  type = object({
    name           = string
    size           = string
    admin_user     = string
    admin_password = string
    os_type        = optional(string, "Windows")
    public_ip_id   = optional(string)
  })
  description = <<EOF
Virtual machine configuration settings including:
  `name`           - The name of the virtual machine
  `size`           - The SKU size of the virtual machine (e.g., Standard_DS2_v2)
  `admin_user`     - The administrative username for the VM
  `admin_password` - The administrative password for the VM
  `os_type`        - (Optional) The OS type, either "Windows" or "Linux". Defaults to "Windows"
  `public_ip_id`   - (Optional) The ID of a public IP to associate with the VM
EOF

  validation {
    condition     = contains(["Windows", "Linux"], var.vm_config.os_type)
    error_message = "OS type must be either 'Windows' or 'Linux'."
  }
}

variable "image_reference" {
  type = object({
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
  description = <<EOF
Virtual machine image reference configuration including:
  `publisher` - The publisher of the image used to create the VM
  `offer`     - The offer of the image used to create the VM
  `sku`       - The SKU of the image used to create the VM
  `version`   - The version of the image used to create the VM
  `plan`      - (Optional) The marketplace image plan configuration containing:
    `name`      - The plan name
    `product`   - The product name
    `publisher` - The publisher ID
EOF

  validation {
    condition = var.image_reference.plan == null || (
      can(regex("^[a-zA-Z0-9-]+$", var.image_reference.plan.name)) &&
      can(regex("^[a-zA-Z0-9-]+$", var.image_reference.plan.product)) &&
      can(regex("^[a-zA-Z0-9-]+$", var.image_reference.plan.publisher))
    )
    error_message = "Plan properties must contain only alphanumeric characters and hyphens."
  }
}

variable "os_disk" {
  type = object({
    storage_account_type = optional(string, "Standard_LRS")
    size_gb              = optional(number, 128)
  })
  description = <<EOF
OS disk configuration including:
  `storage_account_type` - (Optional) The type of storage account for the OS disk. Defaults to "Standard_LRS"
  `size_gb`             - (Optional) The size of the OS disk in GB. Defaults to 128
EOF
  default     = {}
}

variable "monitoring" {
  type = object({
    azure_monitor_agent_enabled = optional(bool, false)
    log_analytics = optional(object({
      resource_id    = string
      workspace_name = string
    }))
  })
  description = <<EOF
Monitoring configuration settings including:
  `azure_monitor_agent_enabled` - (Optional) Enable Azure Monitor Agent. Defaults to false
  `log_analytics`              - (Optional) Log Analytics configuration containing:
    `resource_id`        - The Log Analytics workspace resource ID
    `workspace_name`     - The Log Analytics workspace name
EOF
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to all resources"
  default     = {}
}

variable "is_windows" {
  description = "Boolean flag to determine if running on Windows"
  type        = bool
  default     = true
}
