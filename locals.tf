# locals {
#   selected_subnet_name = "snet-app-siva"

#   selected_subnet_id = module.avm-res-network-subnet[local.selected_subnet_name].resource_id

#   # selectedapp_subnet_name = "snet-ado-payal"
#   # selectedapp_subnet_id = module.avm-res-network-subnet[local.selectedapp subnet].resource_id
# }


#   subnet_id           = local.selected_subnet_id

# locals {
#   subnet_name = ["snet-app-siva",
#      "snet-ado-payal",
#       "snet-psql-siva"
#   ]
#   subnet_ids = {
#     for name in local.subnet_name :
#     name => module.avm-res-network-subnet[name].resource_id
#   }
# }
