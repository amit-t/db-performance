# Installation Guide

This guide covers how to install the DB Performance Monitoring Suite on an Amazon EC2 instance.

## System Requirements

- Amazon EC2 Linux instance (Amazon Linux 2 or newer recommended)
- AWS CLI installed and configured with appropriate permissions
- Database client installed (MySQL or PostgreSQL)
- Bash shell
- Network access to target database instances
- At least 100MB of free disk space for reports

## Step-by-Step Installation

### 1. Install Required Packages

For MySQL monitoring:

```bash
# Amazon Linux 2
sudo yum install -y mariadb

# Amazon Linux 2023
sudo dnf install -y mariadb105

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y mysql-client
```

For PostgreSQL monitoring:

```bash
# Amazon Linux 2
sudo amazon-linux-extras install postgresql12

# Amazon Linux 2023
sudo dnf install -y postgresql15

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y postgresql-client
```

### 2. Install AWS CLI (if not already installed)

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 3. Configure AWS CLI

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., us-east-1)
- Default output format (json recommended)

### 4. Clone the Repository

```bash
git clone https://github.com/amit-t/db-performance.git
cd db-performance
```

### 5. Make Scripts Executable

```bash
chmod +x mysql/scripts/mysql_health_check.sh
chmod +x postgres/scripts/postgres_health_check.sh
```

## Verification

To verify your installation:

1. Test database connectivity:

   For MySQL:
   ```bash
   mysql -h <your-mysql-endpoint> -P 3306 -u <username> -p
   ```

   For PostgreSQL:
   ```bash
   psql -h <your-postgres-endpoint> -p 5432 -U <username> -d postgres
   ```

2. Test AWS CLI configuration:
   ```bash
   aws sts get-caller-identity
   ```

   This should return your AWS account information.

## Troubleshooting

### Cannot Connect to Database

- Verify the EC2 instance's security group allows outbound connections to the database port (3306 for MySQL, 5432 for PostgreSQL).
- Ensure the database's security group allows inbound connections from the EC2 instance's IP address.
- Check that the database credentials are correct.

### AWS CLI Errors

- Verify your IAM user has appropriate permissions.
- Check that the AWS region is correct for your database instance.
- Ensure your AWS credentials are valid and not expired.

### Script Execution Errors

- Make sure the scripts have execute permission (`chmod +x`).
- Verify that the required database client is installed correctly.
- Check that all required AWS CLI commands are available.

## Next Steps

After installation, proceed to [Running Scripts](running-scripts.md) to learn how to execute the database health checks.
