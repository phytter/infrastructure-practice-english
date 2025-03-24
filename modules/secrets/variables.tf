variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "google_client_id" {
  description = "Google client ID"
  type        = string
}

variable "google_client_secret" {
  description = "Google client secret"
  type        = string
}

variable "mongodb_url" {
  description = "MongoDB connection URL"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "opensubtitles_api_key" {
  description = "API key for OpenSubtitles"
  type        = string
}

variable "secret_key" {
  description = "Secret key for the application"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}