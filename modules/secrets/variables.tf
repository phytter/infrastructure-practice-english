variable "name_prefix" {
  description = "Prefixo para os nomes dos recursos"
  type        = string
}

variable "google_client_id" {
  type        = string
}

variable "google_client_secret" {
  type        = string
}

variable "mongodb_url" {
  type        = string
}

variable "database_name" {
  type        = string
}

variable "opensubtitles_api_key" {
  type        = string
}

variable "secret_key" {
  type        = string
}

variable "common_tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
}