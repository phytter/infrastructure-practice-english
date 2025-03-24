variable "name_prefix" {
  description = "Prefix for resource names"
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
  description = "Common tags for all resources"
  type        = map(string)
}