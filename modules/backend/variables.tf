variable "name_prefix" {
  description = "Prefixo para os nomes dos recursos"
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das sub-redes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs das sub-redes públicas"
  type        = list(string)
}

variable "backend_image_tag" {
  description = "Tag da imagem do backend"
  type        = string
}

variable "ecr_repository" {
  description = "Repositório ECR"
  type        = string
}

variable "aws_region" {
  description = "Região da AWS"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
}

variable "min_instances" {
  description = "Número mínimo de instâncias"
  type        = number
}

variable "max_instances" {
  description = "Número máximo de instâncias"
  type        = number
}

variable "scale_out" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}

variable "scale_in" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}
