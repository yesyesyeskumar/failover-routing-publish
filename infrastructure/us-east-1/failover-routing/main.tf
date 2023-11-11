





resource "aws_route53recoveryreadiness_recovery_group" "app_recovery_group" {
  recovery_group_name = "app-recovery-group"
  cells = [
    aws_route53recoveryreadiness_cell.app_recovery_cell_east.arn,
    aws_route53recoveryreadiness_cell.app_recovery_cell_west.arn
    
  ]
}

resource "aws_route53recoveryreadiness_cell" "app_recovery_cell_east" {
  cell_name = "app-recovery-cell-east"
}

resource "aws_route53recoveryreadiness_cell" "app_recovery_cell_west" {
  cell_name = "app-recovery-cell-west"
}

resource "aws_route53recoveryreadiness_resource_set" "app_resource_set" {
  resource_set_name = "app-resource-set"
  resource_set_type = "AWS::Route53::HealthCheck"

  resources {
    resource_arn = "<east_health_check_arn>"

  }

  resources {
    resource_arn = "<west_health_check_arn>"

  }
}

resource "aws_route53recoveryreadiness_readiness_check" "app_readiness_check" {
  readiness_check_name = "app-readiness-check"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.app_resource_set.resource_set_name
  tags = {
    Name = "app-readiness-check"
  }
}



resource "aws_route53recoverycontrolconfig_cluster" "app_recovery_cluster" {
  name = "app-recovery-cluster"
}

resource "aws_route53recoverycontrolconfig_control_panel" "app_control_panel" {
  name        = "appControlPanel"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.app_recovery_cluster.arn
}

resource "aws_route53recoverycontrolconfig_routing_control" "celleast_routing_control" {
  name        = "celleast"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.app_recovery_cluster.arn
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.app_control_panel.arn
}

resource "aws_route53_health_check" "celleast_routing_control_health_check" {
  type              = "RECOVERY_CONTROL"
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.celleast_routing_control.arn

  tags = {
    Name = "CellEastHealthCheck"
  }
}

resource "aws_route53recoverycontrolconfig_routing_control" "cellwest_routing_control" {
  name        = "cellwest"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.app_recovery_cluster.arn
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.app_control_panel.arn
}

resource "aws_route53_health_check" "cellwest_routing_control_health_check" {
  type              = "RECOVERY_CONTROL"
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.cellwest_routing_control.arn

  tags = {
    Name = "CellWestHealthCheck"
  }
}

resource "aws_route53recoverycontrolconfig_safety_rule" "app_safety_rule" {
  asserted_controls = [aws_route53recoverycontrolconfig_routing_control.celleast_routing_control.arn, aws_route53recoverycontrolconfig_routing_control.cellwest_routing_control.arn]
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.app_control_panel.arn
  name              = "AtLeastOneHealthy"
  wait_period_ms    = 5000

  rule_config {
    inverted  = false
    threshold = 1
    type      = "ATLEAST"
  }
}