module "storage_account_public" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"

  name                     = var.storage_acc_public.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_kind             = var.storage_acc_public.account_kind
  access_tier              = var.storage_acc_public.access_tier
  account_replication_type = var.storage_acc_public.account_replication_type

  is_hns_enabled = var.storage_acc_public.is_hns_enabled
  sftp_enabled   = var.storage_acc_public.sftp_enabled

  public_network_access_enabled   = var.storage_acc_public.public_network_access_enabled
  shared_access_key_enabled       = var.storage_acc_public.shared_access_key_enabled
  allow_nested_items_to_be_public = var.storage_acc_public.allow_nested_items_to_be_public # Prevents nested blobs from being public

  allowed_copy_scope               = var.storage_acc_public.allowed_copy_scope
  cross_tenant_replication_enabled = var.storage_acc_public.cross_tenant_replication_enabled

  network_rules = {
    default_action             = var.storage_acc_public_network_rules.default_action
    bypass                     = var.storage_acc_public_network_rules.bypass
    ip_rules                   = var.storage_acc_public_network_rules.ip_rules
    virtual_network_subnet_ids = [azurerm_subnet.pep.id]
    #  private_link_access = {
    #     endpoint_resource_id = private_link_access.value.endpoint_resource_id #storageDataScanner
    #     endpoint_tenant_id =  private_link_access.value.endpoint_tenant_id
    #  }
  }
  
  # role_assignments = {
  #   st_acc_read_role = {
  #     role_definition_id_or_name = "Storage Blob Data Reader"
  #     principal_id = data.azurerm_client_config.current.object_id
  #   }
  # }
  # role_assignments = var.storage_acc_public.role_assignments
}

resource "azurerm_storage_container" "storage_public_container" {
  for_each              = toset(var.storage_account_pub_containers)
  name                  = each.value
  storage_account_id    = module.storage_account_public.resource_id
  container_access_type = "private"

  depends_on = [module.storage_account_public]
}

#Create Storage account local user with ssh keys for SFTP Clients
resource "azurerm_storage_account_local_user" "sftp_user" {
   for_each = azurerm_storage_container.storage_public_container
  # name = substr(lower(replace(each.key, "/[^a-z0-9]/", "")), 0, 64)
  name = "sftp${lower(replace(each.key, "/[^a-z0-9]/", ""))}"

  storage_account_id   = module.storage_account_public.resource_id
  home_directory       = "/${each.key}"
  ssh_key_enabled      = true
  ssh_password_enabled = false

  ssh_authorized_key {
    key         = trimspace(azurerm_key_vault_secret.ssh_key_public_kv[each.key].value)
    description = "Default SFTP SSH Key"
  }
  dynamic "permission_scope" {
    for_each = azurerm_storage_container.storage_public_container
    content {
      permissions {
        read   = true
        write  = true
        delete = true
        list   = true
        create = true
      }
      service       = "blob"
      resource_name = permission_scope.value.name
    }
  }
}

resource "tls_private_key" "rsa_sftp_clients" {
  # for_each = toset(var.storage_account_pub_containers)
  for_each = azurerm_storage_container.storage_public_container
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_key_public_kv" {
  for_each = tls_private_key.rsa_sftp_clients
  key_vault_id    = module.keyvault.resource_id
  name = "ssh-${each.key}"
  # value           = tls_private_key.rsa-sftp-clients[each.key].public_key_openssh
  value = each.value.public_key_openssh
  content_type    = "application/x-pem-file"
  expiration_date = null #expiration date
  not_before_date = null
  # tags            = var.tags
  depends_on = [tls_private_key.rsa_sftp_clients]
}

# resource "azurerm_role_assignment" "storage_acc_pub_role" {
#   for_each = var.st_acc_public_role_assignments

#   name                                   = each.value.name
#   principal_id                           = each.value.principal_id
#   principal_type                         = each.value.principal_type
#   role_definition_id                     = each.value.role_definition_id_or_name 
#   role_definition_name                   = each.value.role_definition_id_or_name
#   scope                                  = module.storage_acc_public.resource_id
# }
# containers = {
#     blob_container0 = {
#       name = "blob-container-${random_string.this.result}-0"
#       role_assignments = {
#         rbac_storage_blob_data_contributor = {
#           role_definition_id_or_name = "Storage Blob Data Contributor"
#           principal_id               = data.azurerm_client_config.current.object_id
#         }
#       }
#     }
#     blob_container1 = {
#       name = "blob-container-${random_string.this.result}-1"
#       role_assignments = {
#         rbac_storage_blob_data_reader = {
#           role_definition_id_or_name = "Storage Blob Data Reader"
#           principal_id               = data.azurerm_client_config.current.object_id
#         }
#       }
#     }

####################################################################################

module "storage_account_private" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"

  name                             = var.storage_acc_private.name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  account_kind                     = var.storage_acc_private.account_kind
  account_tier                     = var.storage_acc_private.account_tier
  access_tier                      = var.storage_acc_private.access_tier
  account_replication_type         = var.storage_acc_private.account_replication_type
  cross_tenant_replication_enabled = var.storage_acc_private.cross_tenant_replication_enabled
  shared_access_key_enabled        = var.storage_acc_private.shared_access_key_enabled
  is_hns_enabled                   = var.storage_acc_private.is_hns_enabled
  allowed_copy_scope               = var.storage_acc_private.allowed_copy_scope #From storage account in the same Microsoft Entra tenant
  allow_nested_items_to_be_public  = var.storage_acc_private.allow_nested_items_to_be_public
  public_network_access_enabled    = var.storage_acc_private.public_network_access_enabled

  network_rules = {
    default_action             = var.storage_acc_private_network_rules.default_action
    bypass                     = var.storage_acc_private_network_rules.bypass
    ip_rules                   = var.storage_acc_private_network_rules.ip_rules
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }
  # private_endpoints = {
  #   storage_endpoint = {
  #     name  = "name-endpoint"
  #     private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
  #     subnet_resource_id            = module.virtual_network.subnets["private_endpoints"].resource_id
  #   }
  # }

  # role_assignments = var.storage_acc_public.role_assignments
}

resource "azurerm_storage_container" "storage_private_container" {
  for_each              = toset(var.storage_account_pri_containers)
  name                  = each.value
  storage_account_id    = module.storage_account_private.resource.id
  container_access_type = "private"

  depends_on = [module.storage_account_private]
}

# resource "azurerm_key_vault_secret" "ssh_key_private_kv" {
#   key_vault_id    = module.keyvault.resource_id
#   name            = var.kv_secret_pri_ssh_key_name_dev
#   value           = tls_private_key.rsa_sftp_clients.private_key_pem
#   content_type    = "application/x-pem-file"
#   expiration_date = null
#   not_before_date = null
#   # tags            = var.tags
#   depends_on = [tls_private_key.rsa_sftp_clients]
# }

# Enable Microsoft Defender for all storage accounts in the subscription
# resource "azurerm_security_center_subscription_pricing" "storage_defender" {
#   tier          = "Standard"
#   resource_type = "StorageAccounts"
# }
