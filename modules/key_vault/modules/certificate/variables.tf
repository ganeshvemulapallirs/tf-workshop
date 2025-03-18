variable "key_vault_id" {
  type        = string
  description = "ID of the KeyVault the secrets will be stored in"
}

variable "key_vault_certificates" {
  type = map(string)
}
