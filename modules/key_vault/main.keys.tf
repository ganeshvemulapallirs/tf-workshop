module "keys" {
  source   = "./modules/key"
  for_each = var.keys

  opts                  = each.value.key_opts
  type                  = each.value.key_type
  key_vault_resource_id = azurerm_key_vault.this.id
  name                  = each.value.name
  curve                 = each.value.curve
  expiration_date       = each.value.expiration_date
  size                  = each.value.key_size
  not_before_date       = each.value.not_before_date
  tags                  = each.value.tags
  rotation_policy       = each.value.rotation_policy
  role_assignments      = each.value.role_assignments

  depends_on = [
    azurerm_private_endpoint.this
  ]
}

