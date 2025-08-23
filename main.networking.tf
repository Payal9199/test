# module "avm-res-network-subnet" {
#   source = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
#   version = "0.8.0"

#   for_each = {for subnet in var.subnet_config: subnet.name => subnet}

#   virtual_network = {
#     resource_id = azurerm_virtual_network.vnet.id
#   }
#   name             = each.value.name
#   address_prefixes = [each.value.address_prefix]
# }

