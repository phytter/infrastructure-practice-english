# Secrets Manager secret for backend environment variables
resource "aws_secretsmanager_secret" "backend" {
  name        = "${var.name_prefix}-secrets-api"
  description = "Environment variables for the Practice English backend"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }
}

# Secret values
resource "aws_secretsmanager_secret_version" "backend" {
  secret_id = aws_secretsmanager_secret.backend.id
  
  secret_string = jsonencode({
    GOOGLE_CLIENT_ID            = var.google_client_id
    GOOGLE_CLIENT_SECRET            = var.google_client_secret
    MONGODB_URL            = var.mongodb_url
    DATABASE_NAME            = var.database_name
    OPENSUBTITLES_API_KEY            = var.opensubtitles_api_key
    # MONGODB_URI            = var.mongodb_connection_string
    SECRET_KEY                = var.secret_key
    ENVIRONMENT            = terraform.workspace
    ALGORITHM               = "HS256"
    PORT                   = "8000"
  })
}