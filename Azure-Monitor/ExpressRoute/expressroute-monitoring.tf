# ExpressRoute Monitoring Rules

# Circuit Status Alert
resource "azurerm_monitor_metric_alert" "er_circuit_status" {
  name                = "er-circuit-status"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  scopes              = [var.expressroute_circuit_id]
  description         = "Alert when ExpressRoute circuit status is not 'Enabled'"
  severity            = 0  # Critical

  criteria {
    metric_namespace = "Microsoft.Network/expressRouteCircuits"
    metric_name      = "circuit_status"
    aggregation      = "Average"
    operator         = "NotEquals"
    threshold        = 1
  }

  window_size = "PT1M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# BGP Peer Status Alert
resource "azurerm_monitor_metric_alert" "er_bgp_status" {
  name                = "er-bgp-status"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  scopes              = [var.expressroute_circuit_id]
  description         = "Alert when BGP peer status is down"
  severity            = 0  # Critical

  criteria {
    metric_namespace = "Microsoft.Network/expressRouteCircuits"
    metric_name      = "bgp_peer_status"
    aggregation      = "Average"
    operator         = "Equals"
    threshold        = 0
  }

  window_size = "PT1M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Bandwidth Usage Alert
resource "azurerm_monitor_metric_alert" "er_bandwidth" {
  name                = "er-bandwidth-usage"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  scopes              = [var.expressroute_circuit_id]
  description         = "Alert when bandwidth usage exceeds 80% for 5 minutes"
  severity            = 2  # Warning

  criteria {
    metric_namespace = "Microsoft.Network/expressRouteCircuits"
    metric_name      = "bandwidth_usage_percent"
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