module "secrets" {
  source   = "./modules/secret"
  for_each = var.secrets

  key_vault_resource_id = azurerm_key_vault.this.id
  name                  = each.value.name
  value                 = var.secrets_value[each.key]
  content_type          = each.value.content_type
  expiration_date       = each.value.expiration_date
  not_before_date       = each.value.not_before_date
  tags                  = each.value.tags
  role_assignments      = each.value.role_assignments

  depends_on = [
    azurerm_private_endpoint.this
  ]
}
