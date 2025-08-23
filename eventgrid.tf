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

# resource "azurerm_user_assigned_identity" "eventhub_sub_identity" {
#   name                = "id-eh-sub-zeus-test"
#   location            = var.location
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_eventgrid_event_subscription" "eventhub_sub" {
#   name                  = "event-sub-zeus-test"
#   scope                 = azurerm_eventgrid_system_topic.sftp_blob_topic.id
#   event_delivery_schema = "EventGridSchema"

#   eventhub_endpoint_id = azurerm_eventhub.zeus_blobsync.id
#   included_event_types = ["Microsoft.Storage.BlobCreated"]

#   delivery_identity {
#     type = "UserAssigned"
#   }
#   advanced_filtering_on_arrays_enabled = true
# }

# resource "azurerm_eventhub" "zeus_blobsync" {
#   name              = "blobsync"
#   namespace_id      = module.avm-res-eventhub-namespace.id
#   partition_count   = 1
#   message_retention = 1 #days
# }

# # resource "azurerm_eventhub_namespace" "zeus_namespace" {
# #   name                = "vendor-zeus-filesync-test-namespace"
# #   location            = var.location
# #   resource_group_name = var.resource_group_name
# #   sku                 = "Standard"
# #   capacity            = 1

# #   network_rulesets = [{
# #     default_action                 = "Allow"
# #     ip_rule                        = []
# #     public_network_access_enabled  = true
# #     trusted_service_access_enabled = true
# #     virtual_network_rule           = []
# #   }]

# #   identity {
# #     type         = "SystemAssigned, UserAssigned"
# #     identity_ids = [azurerm_user_assigned_identity.eventhub_sub_identity.id]
# #   }
# # }
# module "avm-res-eventhub-namespace" {
#   source  = "Azure/avm-res-eventhub-namespace/azurerm"
#   version = "0.1.0"

#   name                = "vendor-zeus-filesync-test-namespace"
#   location            = var.location
#   resource_group_name = var.resource_group_name

#   sku = {
#     name     = "Standard"
#     capacity = 1
#   }

#   network_rulesets = [{
#     default_action                 = "Allow"
#     ip_rule                        = []
#     public_network_access_enabled  = true
#     trusted_service_access_enabled = true
#     virtual_network_rule           = []
#   }]

#   identity = {
#     type         = "SystemAssigned, UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.eventhub_sub_identity.id]
#   }
# }

# # module "zeus_servicebus_namespace" {
# #   source  = "Azure/avm-res-servicebus-namespace/azurerm"
# #   version = "0.4.0"

# #   name                = "zeus-filesync-test-namespace"
# #   location            = var.location
# #   resource_group_name = var.resource_group_name
# #   sku                 = "Standard"
# # }
# # resource "azurerm_servicebus_queue" "filequeue_queue" {
# #   name                = "zeus-filequeue"
# #   namespace_id      = module.zeus_servicebus_namespace.resource_id
# # }
# # resource "azurerm_eventgrid_system_topic_event_subscription" "blob_created_to_sb" {
# #   name                           = "zeus-servicebus-topic-test"
# #   system_topic                   = azurerm_eventgrid_system_topic.sftp_blob_topic.name
# #   resource_group_name            = var.resource_group_name
# #   service_bus_queue_endpoint_id = azurerm_servicebus_queue.filequeue_queue.id
# #   included_event_types           = [
# #     "Microsoft.Storage.BlobCreated",
# #     "Microsoft.Storage.BlobDeleted"
# #   ]
# #   event_delivery_schema          = "EventGridSchema"

# #   advanced_filtering_on_arrays_enabled = true

# #   depends_on = [
# #     azurerm_eventgrid_system_topic.sftp_blob_topic
# #   ]
# # }


# # # resource "azurerm_servicebus_namespace" "zeus_servicebus_namespace" {
# # #   name                = "zeus-filesync-test-namespace"
# # #   location            = var.location
# # #   resource_group_name = var.resource_group_name
# # #   sku                 = "Standard"
# # # }


# # module "avm-res-eventhub-namespace" {
# #   source  = "Azure/avm-res-eventhub-namespace/azurerm"
# #   version = "0.1.0"
# #   # insert the 3 required variables here
# # }
