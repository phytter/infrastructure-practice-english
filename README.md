# infrastructure-practice-english

## Project Description

This project uses Terraform to manage the infrastructure of an English practice application. It configures AWS resources, including VPC, subnets, security groups, load balancers, ECS clusters, and more.

## Purpose

The purpose of this project is to provide a scalable and secure infrastructure, enabling efficient resource management and deployment automation.

## Main Components

- **VPC and Subnets**: Configuration of a VPC with public and private subnets.
- **Security Groups**: Definition of security rules to control network traffic.
- **Load Balancers**: Configuration of ALBs to distribute traffic between backend and frontend instances.
- **ECS Clusters**: Management of ECS clusters to run Docker containers.
- **Auto Scaling**: Configuration of auto scaling policies to automatically adjust the number of instances based on load.

## Execution Guide

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid credentials.
- AWS account with appropriate permissions to create resources.

### Steps to Reproduce and Execute

1. **Clone the Repository**

   ```sh
   git clone https://github.com/phytter/infrastructure-practice-english.git
   cd infrastructure-practice-english
   ```

2. **Initialize Terraform**

   ```sh
   terraform init
   ```

3. **Select the Workspace**

   ```sh
   terraform workspace select staging || terraform workspace new staging
   ```

4. **Plan the Infrastructure**

   ```sh
   terraform plan -var-file="environments/staging/terraform.tfvars"
   ```

5. **Apply the Changes**

   ```sh
   terraform apply -var-file="environments/staging/terraform.tfvars"
   ```

6. **Destroy the Infrastructure (if necessary)**

   ```sh
   terraform destroy -var-file="environments/staging/terraform.tfvars"
   ```

### Sensitive Variables

Make sure to define the following sensitive variables in your environment or through variable files:

- `TF_VAR_google_client_id`
- `TF_VAR_google_client_secret`
- `TF_VAR_mongodb_url`
- `TF_VAR_database_name`
- `TF_VAR_opensubtitles_api_key`
- `TF_VAR_secret_key`
- `TF_VAR_nextauth_url`

## Related Projects

- [App Practice English](https://github.com/phytter/app-practice-english)

- [API Practice English](https://github.com/phytter/api-practice-english)

### Contribution

Contributions are welcome! Feel free to open issues or submit pull requests.

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
