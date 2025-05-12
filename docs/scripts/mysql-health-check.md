# MySQL Health Check Script

## Overview

The MySQL Health Check script provides comprehensive monitoring and analysis for MySQL databases, with specific optimizations for AWS RDS and Aurora MySQL instances. It generates a detailed HTML report with color-coded metrics and recommendations.

## Features

The script collects metrics across multiple areas:

### Database Structure Analysis
- **Database Size Analysis**: Overall and per-database size metrics
- **Table Size Analysis**: Identification of largest tables
- **Table Fragmentation**: Detection of fragmented tables that might need optimization

### Performance Metrics
- **InnoDB Buffer Pool**: Hit ratio and utilization metrics
- **Query Analysis**: Identification of top slow queries and I/O consuming queries
- **Query Cache Effectiveness**: Hit ratio and performance metrics (if enabled)
- **Temporary Table Statistics**: Analysis of memory vs. disk-based temporary tables

### Index Usage
- **Redundant Indexes**: Detection of indexes that duplicate functionality
- **Unused Indexes**: Identification of indexes that are not being utilized

### Resource Monitoring
- **Connection Usage Trends**: Current, maximum, and historical connection statistics
- **Lock Contention**: Identification of waiting transactions and potential deadlocks
- **Long-Running Transactions**: Detection of transactions that could cause performance issues
- **Disk Space Health**: Usage by schema and available free space monitoring

### Configuration Analysis
- **Performance Parameters**: Analysis of key MySQL configuration settings
- **Configuration Drift**: Comparison against best practices with recommendations
- **Logging Parameters**: Evaluation of current logging settings

### Security Analysis
- **User Privileges**: Audit of users with elevated permissions
- **Error Log Monitoring**: Extraction and analysis of recent errors and warnings

### Specialized Features
- **Replication Health**: Status, lag, and error detection for replicated instances
- **Resource Usage by User**: Tracking of resource consumption by user/application
- **Aurora-specific Metrics**: Specialized metrics for Aurora MySQL instances

## Usage

Run the script from an EC2 instance that has network access to your MySQL database:

```bash
./mysql_health_check.sh
```

You'll be prompted to enter:
1. RDS MySQL instance endpoint URL or Aurora MySQL Primary instance endpoint URL
2. Port number
3. Database name
4. RDS Master User Name
5. Password
6. Company Name (for report naming)

## Output

The script generates an HTML report named in this format:
```
<CompanyName>_<DatabaseIdentifier>_report_<date>.html
```

## Example Report

The HTML report is organized into sections, each focusing on a specific aspect of database health. Here's a sample from the output:

```html
<font face="verdana" color="#ff6600">InnoDB Buffer Pool Hit Ratio: </font>
<table border="1">
  <tr><th>Buffer Pool Hit Ratio</th></tr>
  <tr><td>99.7%</td></tr>
</table>
<font face="verdana" color="#0099cc">Note: A high hit ratio (>95%) indicates good buffer pool utilization. Lower ratios may indicate your buffer pool size is too small.</font>
```

## Compatibility

This script works well with MySQL 5.7 and newer versions, including:
- MySQL 5.7
- MySQL 8.0
- AWS RDS MySQL
- Aurora MySQL

## Requirements

- MySQL client installed on the executing machine
- AWS CLI configured (for AWS-specific features)
- Database user with read permissions on performance_schema and information_schema
