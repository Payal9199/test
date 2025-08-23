# User Assigned Identity
resource "azurerm_user_assigned_identity" "eventhub_sub_identity" {
  name                = "id-eh-sub-zeus-test"
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_resource_group.zeus_rg]
}

# resource "azurerm_eventgrid_system_topic" "sftp_blob_topic" {
#   name                   = "storage-sftp-blob-topic"
#   resource_group_name    = var.resource_group_name
#   location               = var.location
#   source_arm_resource_id = module.storage_account_public.resource_id
#   topic_type             = "Microsoft.Storage.StorageAccounts"

#   identity {
#     identity_ids = [azurerm_user_assigned_identity.eventhub_sub_identity.id]
#     type         = "UserAssigned"
#   }
# }

module "avm-res-eventhub-namespace" {
  source  = "Azure/avm-res-eventhub-namespace/azurerm"
  version = "0.1.0"

  name                = "vendor-zeus-filesync-test-namespace-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"
  capacity = 1

  public_network_access_enabled = true  # public network access enabled for the EventHub Namespace
  local_authentication_enabled = true

  network_rulesets = {
  default_action                 = "Allow"
  public_network_access_enabled  = true
  trusted_service_access_enabled = true
  ip_rule                        = []
  virtual_network_rule           = []
}

  event_hubs = {
  blobsynctestb = {
    name                = "blobsyncvsagsyu"
    namespace_name      = "vendor-zeus-filesync-test-namespace-01" # same as module namespace name
    resource_group_name = var.resource_group_name
    partition_count     = 1
    message_retention   = 1
    #  destination = object({
    #     name                = optional(string, "EventHubArchive.AzureBlockBlob")
    #     archive_name_format = string
    #     blob_container_name = string
    #     storage_account_id  = string
    #   })
  }
}
  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.eventhub_sub_identity.id]
  }

#   private_endpoints = {
#     eventhub_endpoint = {                     # use a map key
#       name               = "pe-eh-zeus-test"
#       subnet_resource_id = azurerm_subnet.pep.id
#       subresource_names  = "namespace" # array instead of string
#       private_dns_zone_resource_ids = []
#     }
#   }
#   private_endpoints_manage_dns_zone_group = true

  # Optional: Role assignments for Event Grid
#  role_assignments = {
#   blobsync_receiver_role_dev_team = {
#     scope                = module.avm-res-eventhub-namespace.resource_id  # parent namespace
#     role_definition_id_or_name = "Azure Event Hubs Data Receiver"
#     principal_id         = "" # replace with Simranjeet's User Assigned Identity principal ID
#   },
#    blobsync_receiver_role_ = {
#     scope                = module.avm-res-eventhub-namespace.resource_id  # parent namespace
#     role_definition_id_or_name = "Azure Event Hubs Data Receiver"
#     principal_id         = "" # replace with managed identity product-import-se
#   },
  # blobsync_role = {
  #   scope                = module.avm-res-eventhub-namespace.resource_eventhubs["blobsynctestb"].id
  #   role_definition_id_or_name = "Azure Event Hubs Data Sender"
  #   principal_id         = azurerm_user_assigned_identity.eventhub_sub_identity.principal_id
  # }
# }
# tags = var.tags
}

# # Event Grid Subscription to Event Hub
# resource "azurerm_eventgrid_system_topic_event_subscription" "eventhub_sub_new" {
#   name                = "eventgrid-sub-001"
#   resource_group_name = var.resource_group_name
#   system_topic        = module.storage_account_public.resource_id

#   event_delivery_schema = "EventGridSchema"
#   included_event_types  = ["Microsoft.Storage.BlobCreated"]

#   eventhub_endpoint_id = module.avm-res-eventhub-namespace.resource_eventhubs["blobsynctestb"].id

#   delivery_identity {
#     type                   = "UserAssigned"
#     user_assigned_identity = azurerm_user_assigned_identity.eventhub_sub_identity.id
#   }

#   advanced_filtering_on_arrays_enabled = true
# }

resource "azurerm_eventgrid_event_subscription" "blob_to_eventhub" {
  name = "eventgrid-sub-001"
  scope = module.storage_account_public.resource_id

  event_delivery_schema = "EventGridSchema"
  included_event_types  = ["Microsoft.Storage.BlobCreated"]

  eventhub_endpoint_id = module.avm-res-eventhub-namespace.resource_eventhubs["blobsynctestb"].id

  delivery_identity {
    type                   = "UserAssigned"
    user_assigned_identity = azurerm_user_assigned_identity.eventhub_sub_identity.id
  }

  advanced_filtering_on_arrays_enabled = true

  depends_on = [
    module.avm-res-eventhub-namespace,
    azurerm_role_assignment.eventgrid_to_eventhub
  ]

}

# Sometimes role assignment propagation takes time -> add delay
resource "time_sleep" "wait_for_role" {
  depends_on = [azurerm_role_assignment.eventgrid_to_eventhub]
  create_duration = "60s"
}
# # # Role Assignment: Event Grid -> Event Hub
# resource "azurerm_role_assignment" "eventgrid_to_eventhub" {
#   scope                = module.avm-res-eventhub-namespace.resource_eventhubs["blobsynctestb"].id
#   role_definition_name = "Azure Event Hubs Data Sender"
#   principal_id         = azurerm_user_assigned_identity.eventhub_sub_identity.principal_id
# }


resource "azurerm_eventhub_authorization_rule" "blobsync_policy_test" {
  name                = "policy-zeus-test-jhcbdsg"
  namespace_name      = module.avm-res-eventhub-namespace.resource_eventhubs["blobsynctestb"].namespace_name
  eventhub_name       = module.avm-res-eventhub-namespace.resource_eventhubs["blobsynctestb"].name

  resource_group_name = var.resource_group_name

  listen = true
  send   = true
  manage = true
}

resource "azurerm_role_assignment" "eventgrid_to_eventhub" {
  scope                = module.avm-res-eventhub-namespace.resource_eventhubs["blobsynctestb"].id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_user_assigned_identity.eventhub_sub_identity.principal_id
}

# resource "azurerm_private_endpoint" "pe_zeus_eventhub" {
#   name                = "pe-eh-zeus-test"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id   # pep subnet

#   private_service_connection {
#     name                           = "psc-eh-zeus"
#     is_manual_connection           = false
#     private_connection_resource_id = azurerm_eventhub_namespace.zeus_namespace.id
#     subresource_names              = ["namespace"] # Event Hub namespace subresource
#   }
# }

# resource "azurerm_eventhub" "zeus_blobsync" {
#   name              = "blobsync"
#   namespace_id      = azurerm_eventhub_namespace.zeus_namespace.id
#   partition_count   = 1
#   message_retention = 1 #days
# }
