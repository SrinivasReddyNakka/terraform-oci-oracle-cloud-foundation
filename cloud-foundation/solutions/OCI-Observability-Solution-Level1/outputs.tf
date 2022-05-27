# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "ADW_Service_Console_URL" {
  value = module.adw.ADW_Service_Console_URL
}

output "ADW_LOGIN" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}

output "Buckets" {
  value = module.os.buckets
}

output "Oci_Topics_Notifications" {
  value = module.oci_notifications.topics
}

output "Oci_Monitoring_Alarms" {
  value = module.oci_monitoring_alarms.monitoring_alarms
}

output "Oci_Logging_Log_Groups" {
  value = module.oci_logging.log_groups
}

output "Oci_Logging_Logs" {
  value = module.oci_logging.logs
}

output "Oci_Events" {
  value = module.oci_events.events
}