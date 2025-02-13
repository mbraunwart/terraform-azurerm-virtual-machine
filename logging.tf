locals {
  date         = formatdate("YYYYMMDD", timestamp())
  machine_name = var.vm_config.os_type == "Windows" ? azurerm_windows_virtual_machine.vm.0.name : azurerm_linux_virtual_machine.vm.0.name
  event_name   = format("event-%s", local.machine_name)
  perf_name    = format("perf-%s", local.machine_name)
  syslog_name  = format("syslog-%s", local.machine_name)
}

resource "azurerm_monitor_data_collection_rule" "windows-rule" {
  count = var.vm_config.os_type == "Windows" ? 1 : 0

  name                = format("diag-%s", azurerm_windows_virtual_machine.vm.0.name)
  location            = var.location
  resource_group_name = var.resource_group_name

  data_sources {
    windows_event_log {
      name    = local.event_name
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Security!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }
    performance_counter {
      name                          = local.perf_name
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available Bytes",
        "\\LogicalDisk(_Total)\\Free Megabytes",
        "\\Network Interface(*)\\Bytes Total/sec"
      ]
    }
  }

  destinations {
    log_analytics {
      name                  = local.event_name
      workspace_resource_id = var.monitoring.log_analytics.resource_id
    }
    log_analytics {
      name                  = local.perf_name
      workspace_resource_id = var.monitoring.log_analytics.resource_id
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = [local.event_name]
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = [local.perf_name]
  }
}

resource "azurerm_monitor_data_collection_rule" "linux-rule" {
  count = var.vm_config.os_type == "Linux" ? 1 : 0

  name                = format("diag-%s", azurerm_linux_virtual_machine.vm.0.name)
  location            = var.location
  resource_group_name = var.resource_group_name

  data_sources {
    syslog {
      name    = local.syslog_name
      streams = ["Microsoft-Syslog"]
      facility_names = [
        "auth",
        "authpriv",
        "daemon",
        "syslog",
        "user",
        "local0",
        "local1",
        "cron"
      ]
      log_levels = ["Emergency", "Alert", "Critical", "Error", "Warning", "Notice", "Info"]
    }
    performance_counter {
      name                          = local.perf_name
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "Processor(*)\\PercentProcessorTime",
        "Memory\\AvailableMB",
        "Disk(*)\\FreeSpace",
        "Network(*)\\BytesTotal"
      ]
    }
  }

  destinations {
    log_analytics {
      name                  = local.syslog_name
      workspace_resource_id = var.monitoring.log_analytics.resource_id
    }
    log_analytics {
      name                  = local.perf_name
      workspace_resource_id = var.monitoring.log_analytics.resource_id
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = [local.syslog_name]
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = [local.perf_name]
  }
}


resource "azurerm_monitor_data_collection_rule_association" "windows-association" {
  count = var.vm_config.os_type == "Windows" ? 1 : 0

  name                    = format("diag-clr-%s", azurerm_windows_virtual_machine.vm.0.name)
  data_collection_rule_id = azurerm_monitor_data_collection_rule.windows-rule.0.id
  target_resource_id      = azurerm_windows_virtual_machine.vm.0.id
}

resource "azurerm_monitor_data_collection_rule_association" "linux-association" {
  count = var.vm_config.os_type == "Linux" ? 1 : 0

  name                    = format("diag-clr-%s", azurerm_linux_virtual_machine.vm.0.name)
  data_collection_rule_id = azurerm_monitor_data_collection_rule.linux-rule.0.id
  target_resource_id      = azurerm_linux_virtual_machine.vm.0.id
}

resource "azurerm_virtual_machine_extension" "windows-ama" {
  count = var.vm_config.os_type == "Windows" && var.monitoring.azure_monitor_agent_enabled ? 1 : 0

  name                       = format("%s-AzureMonitorWindowsAgent", var.vm_config.name)
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.0.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "linux-ama" {
  count = var.vm_config.os_type == "Linux" && var.monitoring.azure_monitor_agent_enabled ? 1 : 0

  name                       = format("%s-AzureMonitorLinuxAgent", var.vm_config.name)
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.0.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  depends_on = [azurerm_linux_virtual_machine.vm]
}
