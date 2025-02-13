data "azurerm_client_config" "current" {}

resource "azurerm_network_interface" "nic" {
  name                = var.vm_config.name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.vm_config.public_ip_id
  }
}

resource "null_resource" "accept_marketplace_terms" {
  count = var.image_reference.plan != null ? 1 : 0

  provisioner "local-exec" {
    interpreter = var.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
    command = var.is_windows ? (
      "az vm image terms accept --publisher ${var.image_reference.plan.publisher} --offer ${var.image_reference.plan.product} --plan ${var.image_reference.plan.name}"
      ) : (
      "az vm image terms accept --publisher ${var.image_reference.plan.publisher} --offer ${var.image_reference.plan.product} --plan ${var.image_reference.plan.name}"
    )
  }

  triggers = {
    plan_hash = var.image_reference.plan != null ? join(",", [var.image_reference.plan.publisher, var.image_reference.plan.product, var.image_reference.plan.name]) : ""
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count = var.vm_config.os_type == "Windows" ? 1 : 0

  name                  = var.vm_config.name
  computer_name         = var.vm_config.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_config.size
  admin_username        = var.vm_config.admin_user
  admin_password        = var.vm_config.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  os_disk {
    name                 = format("osdisk-%s", var.vm_config.name)
    caching              = "ReadWrite"
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.size_gb
  }

  dynamic "plan" {
    for_each = var.image_reference.plan != null ? [var.image_reference.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    
  }

  depends_on = [null_resource.accept_marketplace_terms]

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = var.vm_config.os_type == "Linux" ? 1 : 0

  name                            = var.vm_config.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_config.size
  admin_username                  = var.vm_config.admin_user
  admin_password                  = var.vm_config.admin_password
  network_interface_ids           = [azurerm_network_interface.nic.id]
  disable_password_authentication = false

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  os_disk {
    name                 = format("osdisk-%s", var.vm_config.name)
    caching              = "ReadWrite"
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.size_gb
  }

  dynamic "plan" {
    for_each = var.image_reference.plan != null ? [var.image_reference.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [null_resource.accept_marketplace_terms]

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
}

