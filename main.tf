terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    oci = {
      source  = "hashicorp/oci"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.15.0"
}

# Variável para escolher o provedor
variable "cloud_provider" {
  description = "O provedor de nuvem para o qual o recurso será provisionado (aws, azure, google, oracle)"
  type        = string
  default     = "aws"
}

# Variáveis comuns
variable "instance_type" {
  description = "Tipo de instância para todos os provedores."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Chave SSH para acesso à instância."
  type        = string
  default     = "iac-terraform"
}

# Variáveis específicas do AWS
variable "aws_region" {
  description = "A região AWS para a instância."
  type        = string
  default     = "us-west-2"
}

variable "aws_ami" {
  description = "ID da AMI AWS para a instância."
  type        = string
  default     = "ami-008fe2fc65df48dac"
}

# Variáveis específicas do Azure
variable "azure_location" {
  description = "A localização do Azure para a instância."
  type        = string
  default     = "East US"
}

variable "azure_image" {
  description = "Imagem do Azure para a instância."
  type        = map(string)
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Variáveis específicas do Google Cloud
variable "google_region" {
  description = "Região do Google Cloud."
  type        = string
  default     = "us-central1"
}

variable "google_image" {
  description = "Imagem do Google Cloud para a instância."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
}

# Variáveis específicas do Oracle Cloud
variable "oci_region" {
  description = "Região do Oracle Cloud."
  type        = string
  default     = "us-ashburn-1"
}

# Providers configurados condicionalmente
provider "aws" {
  region = var.aws_region
  count  = var.cloud_provider == "aws" ? 1 : 0
}

provider "azurerm" {
  features {}
  count = var.cloud_provider == "azure" ? 1 : 0
}

provider "google" {
  region = var.google_region
  count  = var.cloud_provider == "google" ? 1 : 0
}

provider "oci" {
  region = var.oci_region
  count  = var.cloud_provider == "oracle" ? 1 : 0
}

# Recursos condicionalmente provisionados
resource "aws_instance" "app_server" {
  count         = var.cloud_provider == "aws" ? 1 : 0
  ami           = var.aws_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "Minha Maquina AWS"
  }
}

resource "azurerm_linux_virtual_machine" "app_server" {
  count              = var.cloud_provider == "azure" ? 1 : 0
  name               = "MinhaMaquinaAzure"
  location           = var.azure_location
  resource_group_name = azurerm_resource_group.rg.name
  size               = var.instance_type
  admin_username     = "azureuser"
  network_interface_ids = [azurerm_network_interface.main.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = var.azure_image["publisher"]
    offer     = var.azure_image["offer"]
    sku       = var.azure_image["sku"]
    version   = var.azure_image["version"]
  }
}

resource "google_compute_instance" "app_server" {
  count        = var.cloud_provider == "google" ? 1 : 0
  name         = "MinhaMaquinaGoogle"
  machine_type = var.instance_type
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.google_image
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

resource "oci_core_instance" "app_server" {
  count             = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id    = "<your_compartment_ocid>"
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  shape             = var.instance_type
  display_name      = "MinhaMaquinaOracle"

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = "<your_subnet_ocid>"
  }

  source_details {
    source_type = "image"
    image_id    = "<your_image_ocid>"
  }
}

# Saídas de IP público para diferentes provedores
output "instance_public_ip" {
  description = "IP público da instância"
  value       = var.cloud_provider == "aws" ? aws_instance.app_server[0].public_ip :
                 var.cloud_provider == "azure" ? azurerm_public_ip.main.ip_address :
                 var.cloud_provider == "google" ? google_compute_instance.app_server[0].network_interface.0.access_config.0.nat_ip :
                 oci_core_instance.app_server[0].public_ip
}
