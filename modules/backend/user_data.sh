#!/bin/bash
set -e

amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

yum update -y
yum install -y awslogs
yum install -y jq

# Configure the AWS region
sed -i "s/region = .*/region = ${aws_region}/" /etc/awslogs/awscli.conf

# Configure the log group and log stream
cat <<EOF >> /etc/awslogs/config/logs.conf
[/var/log/messages]
log_group_name = /var/log/messages
log_stream_name = {instance_id}
datetime_format = %b %d %H:%M:%S
EOF

systemctl start awslogsd
systemctl enable awslogsd.service

aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.${aws_region}.amazonaws.com

docker pull $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.${aws_region}.amazonaws.com/${ecr_repository}:${image_tag}

# Get secrets from AWS Secrets Manager
SECRETS=$(aws secretsmanager get-secret-value --secret-id ${secrets_name} --query SecretString --output text)

# Create environment file
echo $SECRETS | jq -r 'to_entries | map("\(.key)=\(.value)") | .[]' > /env.list

docker run -d \
  --name practice-english-backend \
  --restart always \
  -p 8000:8000 \
  --env-file /env.list \
  $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.${aws_region}.amazonaws.com/${ecr_repository}:${image_tag}