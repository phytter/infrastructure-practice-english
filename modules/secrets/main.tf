# Verifica se o segredo já existe
data "aws_secretsmanager_secret" "existing_backend" {
  name = "${var.name_prefix}-secrets-api"
}

# Secrets Manager secret for backend environment variables
resource "aws_secretsmanager_secret" "backend" {
  count       = length(data.aws_secretsmanager_secret.existing_backend.arn) == 0 ? 1 : 0
  name        = "${var.name_prefix}-secrets-api"
  description = "Environment variables for the Practice English backend"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [name]
  }
}

# Secret values
resource "aws_secretsmanager_secret_version" "backend" {
  secret_id = length(data.aws_secretsmanager_secret.existing_backend.arn) == 0 ? aws_secretsmanager_secret.backend[0].id : data.aws_secretsmanager_secret.existing_backend[0].id: 
  
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