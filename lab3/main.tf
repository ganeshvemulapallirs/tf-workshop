data "azurerm_client_config" "tenant" {}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${random_pet.prefix.id}-rg"
}

module "keyvault" {
  source                          = "../modules/key_vault"
  name                            = "${random_pet.prefix.id}-kv"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.tenant.tenant_id
  soft_delete_retention_days      = 90
  sku_name                        = "standard"
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.tenant.object_id
    }
  }
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "${random_pet.prefix.id}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "${random_pet.prefix.id}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "${random_pet.prefix.id}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "${random_pet.prefix.id}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.my_terraform_subnet.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}




resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}


resource "azurerm_key_vault_secret" "vm_pwd" {
  name         = "${var.prefix}-vm-password"
  value        = random_password.password.result
  key_vault_id = module.keyvault.resource_id
  depends_on = [
    module.keyvault
  ]
}

module "vm" {
  source                             = "../modules/virtual_machine"
  admin_username                     = "azureuser"
  admin_password                     = random_password.password.result
  generate_admin_password_or_ssh_key = false
  location                           = azurerm_resource_group.rg.location
  name                               = "${var.prefix}-vm"
  computer_name                      = "${var.prefix}-vm"
  resource_group_name                = azurerm_resource_group.rg.name
  os_type                            = "windows"
  sku_size                           = "Standard_DS1_v2"
  zone                               = null

  os_disk = {
    name                 = "testdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  network_interfaces = {
    network_interface_1 = {
      name = "nic-test"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "ipconfig"
          private_ip_subnet_resource_id = azurerm_subnet.my_terraform_subnet.id
          create_public_ip_address      = false
          private_ip_address_allocation = "Dynamic"
          public_ip_address_resource_id = azurerm_public_ip.my_terraform_public_ip.id

        }
      }
    }
  }
}