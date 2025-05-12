# Getting Started

This guide will help you quickly set up and start using the DB Performance Monitoring Suite.

## Prerequisites

### For PostgreSQL Health Check

- Amazon EC2 Linux instance with AWS CLI configured
- PostgreSQL client installed
- Network access to the target RDS/Aurora PostgreSQL instance
- Database user with read permissions on all tables

### For MySQL Health Check

- Amazon EC2 Linux instance with AWS CLI configured
- MySQL client installed
- Network access to the target RDS/Aurora MySQL instance
- Database user with read permissions on all tables

## Installation

1. Clone the repository to your EC2 instance:

```bash
git clone https://github.com/amit-t/db-performance.git
cd db-performance
```

2. Make the appropriate script executable:

For PostgreSQL:
```bash
chmod +x postgres/scripts/postgres_health_check.sh
```

For MySQL:
```bash
chmod +x mysql/scripts/mysql_health_check.sh
```

## Quick Run

### PostgreSQL Health Check

```bash
cd postgres/scripts
./postgres_health_check.sh
```

### MySQL Health Check

```bash
cd mysql/scripts
./mysql_health_check.sh
```

## Next Steps

- Learn more about [PostgreSQL script features](scripts/postgres-health-check.md)
- Learn more about [MySQL script features](scripts/mysql-health-check.md)
- Review [interpreting results](usage/interpreting-results.md) for understanding the output
