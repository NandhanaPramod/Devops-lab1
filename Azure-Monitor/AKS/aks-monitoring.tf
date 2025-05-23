# AKS Monitoring Rules

# Node CPU Usage Alert
resource "azurerm_monitor_metric_alert" "aks_node_cpu" {
  name                = "aks-node-cpu-usage"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when node CPU usage exceeds 80% for 5 minutes"
  severity            = 2  # Warning

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Node Memory Usage Alert
resource "azurerm_monitor_metric_alert" "aks_node_memory" {
  name                = "aks-node-memory-usage"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when node memory usage exceeds 85% for 5 minutes"
  severity            = 2  # Warning

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_usage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Pod Restart Alert
resource "azurerm_monitor_metric_alert" "aks_pod_restart" {
  name                = "aks-pod-restart"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when pod restarts exceed 3 times in 1 hour"
  severity            = 0  # Critical

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "pod_restart_count"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 3
  }

  window_size = "PT1H"
  frequency   = "PT5M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
} 