resource "azurerm_key_vault_certificate" "key-vault-certificate" {
  key_vault_id = var.key_vault_id
  for_each     = var.key_vault_certificates
  name         = each.key
  certificate {
    contents = each.value.contents
    password = each.value.certpass
  }
  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

output "all" {
  value = azurerm_key_vault_certificate.key-vault-certificate
}