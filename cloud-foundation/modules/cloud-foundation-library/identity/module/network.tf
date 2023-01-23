# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs

variable "create_network_persona" {
  type        = bool
  default     = false
  description = "if true, creates a Network-Admins group to manage Network resources in a specific compartment. It also creates a Network-Service group"
}
variable "network_name" {
  type = string 
  default = "Network"
  description = "optional custom name for network identity resources"
}

/* expected defined values 
local.enclosing_compartment - compartment OCID
var.tenancy_ocid - tenancy OCID
var.allow_compartment_deletion - bool
local.prefix - string

*/


# outputs

output "network_compartment" {
    value = var.create_network_persona ? oci_identity_compartment.network[0].id : null 
    description = "ocid of the network compartment"
}


# logic

locals {
  network_name = "${local.prefix}${var.network_name}"
}


# resource or mixed module blocks

resource "oci_identity_compartment" "network" {
  count          = var.create_network_persona ? 1 : 0
  compartment_id = local.enclosing_compartment
  description    = "Landing Zone compartment for all network related resources: VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs, and others."
  name           = local.network_name
  enable_delete  = var.allow_compartment_deletion
}

resource "oci_identity_group" "network" {
  count          = var.create_network_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for managing networking in compartment ${oci_identity_compartment.network[0].name}."
  name           = "${local.network_name}-Admin"
}

resource "oci_identity_group" "network_service" {
  count          =  0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for users of the Networking team to access networks in compartment ${oci_identity_compartment.network[0].name}."
  name           = "${local.network_name}-Service"
}

resource "oci_identity_policy" "network" {
  count          = var.create_network_persona ? 1 : 0
  compartment_id = oci_identity_compartment.network[0].id
  description    = "Landing Zone policy for ${oci_identity_group.network[0].name}'s group to manage Network related services in Landing Zone compartment ${oci_identity_compartment.network[0].name}"
  name           = local.network_name
  statements     = concat(
      # network team in network compartment
      formatlist("allow group ${oci_identity_group.network[0].name} to %s in compartment ${oci_identity_compartment.network[0].name}", [
        "read all-resources", 
        # network related resources
        "manage virtual-network-family", "manage dns", "manage load-balancers", "manage bastion-family",
        # compute/file storage related resources
        "manage mount-targets",
        # standard helper resources
        "manage orm-stacks", "manage orm-jobs", "manage orm-config-source-providers"
      ])
    )
}