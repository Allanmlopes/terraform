<h1>Projeto Multi-Cloud com Terraform</h1>
Este projeto configura e provisiona uma instância de máquina virtual em diferentes provedores de nuvem (AWS, Azure, Google Cloud e Oracle Cloud) usando Terraform. O código foi desenvolvido para ser flexível e adaptável, permitindo que você escolha o provedor de nuvem através de uma variável e configurar automaticamente o ambiente.

<h3>Descrição</h3>
Este projeto utiliza o Terraform para criar uma instância de máquina virtual em um dos provedores de nuvem suportados. Ele inclui suporte para AWS, Azure, Google Cloud e Oracle Cloud, e configura automaticamente o ambiente com base no provedor selecionado. Cada configuração foi cuidadosamente elaborada para simplificar o processo de deploy, com variáveis ajustáveis para facilitar a personalização do tipo de instância, AMI e região.

<h3>Funcionalidades</h3>
Suporte Multi-Cloud: Escolha entre AWS, Azure, Google Cloud e Oracle Cloud usando a variável cloud_provider.
Configuração Personalizável: Variáveis para o tipo de instância, chave SSH, imagem da máquina e região, permitindo ajustes rápidos e reutilização do código.
Provisionamento Seguro: Inclui a possibilidade de configuração de estado remoto para armazenamento seguro e compartilhado do estado do Terraform, ideal para ambientes de equipe.
Saída de IP Público: Após o provisionamento, o código exibe o IP público da instância para facilitar o acesso.

<h2>Estrutura do Código</h2>

<h3>1. Definição dos Provedores</h3>
Cada provedor (AWS, Azure, Google Cloud e Oracle Cloud) é configurado no código e ativado com base no valor da variável cloud_provider. Isso permite que apenas o provedor selecionado seja configurado, garantindo eficiência e simplificação do código.

    variable "cloud_provider" {
      description = "O provedor de nuvem para o qual o recurso será provisionado (aws, azure, google, oracle)"
      type        = string
      default     = "aws"
    }
<h3>2. Variáveis Customizáveis</h3>
As variáveis permitem que você ajuste parâmetros como o tipo de instância, AMI, chave SSH, e a região. Isso facilita o reuso e adapta o projeto a diferentes necessidades.

<h3>3. Condicionais para Provisionamento Multi-Cloud</h3>
O recurso específico de cada provedor é ativado apenas se a variável cloud_provider corresponder ao provedor configurado. Esta abordagem evita a criação de instâncias em múltiplos provedores ao mesmo tempo, oferecendo um controle claro sobre o ambiente de deploy.

    resource "aws_instance" "app_server" {
      count         = var.cloud_provider == "aws" ? 1 : 0
      ami           = var.aws_ami
      instance_type = var.instance_type
      key_name      = var.key_name
      tags = {
        Name = "Minha Maquina AWS"
      }
    }
<h3>4. Saídas</h3>
Após o provisionamento, o código exibe o IP público da instância para facilitar o acesso, independente do provedor.

    output "instance_public_ip" {
      description = "IP público da instância"
      value       = var.cloud_provider == "aws" ? aws_instance.app_server[0].public_ip :
                     var.cloud_provider == "azure" ? azurerm_public_ip.main.ip_address :
                     var.cloud_provider == "google" ? google_compute_instance.app_server[0].network_interface.0.access_config.0.nat_ip :
                     oci_core_instance.app_server[0].public_ip
    }

<h2>Como Usar</h2>

<h3>Clone o Repositório:</h3>

    git clone https://github.com/Allanmlopes/terraform-multi-cloud.git
    cd terraform-multi-cloud
Configurar Variáveis: Modifique as variáveis conforme necessário no arquivo main.tf ou crie um arquivo terraform.tfvars para sobrescrever as variáveis padrão.

Selecionar o Provedor de Nuvem: No terraform.tfvars, defina cloud_provider com o valor desejado (aws, azure, google, ou oracle).

<h3>Inicializar o Terraform:</h3>

    terraform init

<h3>Aplicar o Código:</h3>

    terraform apply

Obter Informações da Instância: Após a execução, o IP público da instância estará disponível na saída.

<h2>Exemplo de Configuração de Variáveis</h2>

Crie um arquivo terraform.tfvars para personalizar a configuração do ambiente:

    cloud_provider = "aws"
    instance_type = "t2.micro"
    aws_region = "us-west-2"
    aws_ami = "ami-008fe2fc65df48dac"
    key_name = "minha-chave-ssh"
    Requisitos
    Terraform versão >= 0.15.0

Contas ativas e configuradas nos provedores de nuvem selecionados (AWS, Azure, Google Cloud ou Oracle Cloud)
Credenciais de autenticação configuradas para cada provedor

<h3>Observações</h3>

Este projeto é ideal para demonstrações e aprendizado em ambientes multi-cloud. Recomendamos evitar o uso em produção sem uma revisão cuidadosa de segurança e escalabilidade.
