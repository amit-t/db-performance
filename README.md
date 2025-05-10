# Database Performance Monitoring Suite

A comprehensive toolkit for monitoring and analyzing the performance of PostgreSQL and MySQL databases, with a focus on AWS RDS and Aurora instances.

## Project Overview

This suite provides detailed health check scripts for PostgreSQL and MySQL databases. The scripts generate HTML reports with extensive metrics, allowing database administrators to:

- Identify performance bottlenecks
- Detect configuration issues
- Monitor resource usage
- Optimize database performance
- Implement best practices
- Ensure database security

## Directory Structure

```
db-performance/
├── postgres/
│   └── scripts/
│       └── postgres_health_check.sh  # PostgreSQL health check script
├── mysql/
│   └── scripts/
│       └── mysql_health_check.sh     # MySQL health check script
└── README.md                         # This file
```

## Available Scripts

### PostgreSQL Health Check

Location: `postgres/scripts/postgres_health_check.sh`

Provides comprehensive health and performance metrics for PostgreSQL databases, focusing on AWS RDS and Aurora PostgreSQL instances.

### MySQL Health Check

Location: `mysql/scripts/mysql_health_check.sh`

Provides comprehensive health and performance metrics for MySQL databases, focusing on AWS RDS and Aurora MySQL instances.

## Features

### Common Features (Both Scripts)

- Database and table size analysis
- Index usage and optimization recommendations
- Performance parameter evaluation
- Slow query identification
- Resource utilization metrics
- HTML report generation

### PostgreSQL-Specific Features

- Vacuum and analyze statistics
- Table bloat analysis
- Sequence utilization
- Extension monitoring
- WAL and checkpoint activity

### MySQL-Specific Features

- InnoDB buffer pool hit ratio and utilization metrics
- Table fragmentation analysis
- Query cache effectiveness evaluation
- Lock contention identification
- Long-running transaction detection
- Replication health monitoring
- User privilege auditing
- Error log analysis
- Configuration drift detection against best practices
- Aurora-specific metrics (for Aurora MySQL instances)

## Requirements

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

## Installation and Usage

### PostgreSQL Health Check

1. Copy `postgres_health_check.sh` to an EC2 instance with PostgreSQL client installed
2. Make the script executable:
   ```
   chmod +x postgres_health_check.sh
   ```
3. Run the script:
   ```
   ./postgres_health_check.sh
   ```
4. Follow the prompts to enter:
   - RDS PostgreSQL instance endpoint URL
   - Port
   - Database name
   - Master username and password
   - Company name (for report naming)
5. The script will generate an HTML report: `<CompanyName>_<DatabaseIdentifier>_report_<date>.html`

### MySQL Health Check

1. Copy `mysql_health_check.sh` to an EC2 instance with MySQL client installed
2. Make the script executable:
   ```
   chmod +x mysql_health_check.sh
   ```
3. Run the script:
   ```
   ./mysql_health_check.sh
   ```
4. Follow the prompts to enter:
   - RDS MySQL instance endpoint URL or Aurora MySQL Primary instance endpoint URL
   - Port
   - Database name
   - Master username and password
   - Company name (for report naming)
5. The script will generate an HTML report: `<CompanyName>_<DatabaseIdentifier>_report_<date>.html`

## Version Compatibility

### PostgreSQL Health Check
- Works with PostgreSQL 9.6 and newer versions

### MySQL Health Check
- Works with MySQL 5.7 and newer versions

## Report Interpretation

The generated HTML reports provide color-coded indicators:
- Green: Good/healthy metrics
- Orange/Yellow: Warning or attention needed
- Red: Critical issue requiring immediate attention

Each section includes notes and recommendations for addressing identified issues.

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Authors

- Vivek Singh - Original PostgreSQL script author
- Amit Tiwari - MySQL script adaptation and enhancements

## License

This project is proprietary and intended for internal use. Please consult the legal team before sharing externally.
