# PostgreSQL Health Check Script

## Overview

The PostgreSQL Health Check script provides comprehensive monitoring and analysis for PostgreSQL databases, with specific optimizations for AWS RDS and Aurora PostgreSQL instances. It generates a detailed HTML report with color-coded metrics and recommendations.

## Features

The script collects metrics across multiple areas:

### Database Structure Analysis
- **Database Size Analysis**: Overall and per-database size metrics
- **Table Size Analysis**: Identification of largest tables and growth patterns
- **Bloat Analysis**: Detection of tables and indexes with bloat that could be reclaimed

### Performance Metrics
- **Buffer Cache Hit Ratio**: Efficiency of the PostgreSQL buffer cache
- **Query Analysis**: Identification of longest running queries and execution patterns
- **Sequential vs. Index Scans**: Analysis of table access methods
- **Checkpoint Statistics**: Frequency and impact of checkpoints

### Index Usage
- **Unused Indexes**: Identification of indexes that are not being utilized
- **Missing Indexes**: Detection of tables that might benefit from additional indexes
- **Index Scans vs. Sequential Scans**: Analysis of query execution plans

### Resource Monitoring
- **Connection Usage**: Current, maximum, and historical connection statistics
- **Transaction Wrap-around**: Risk assessment for transaction ID wraparound
- **Disk Usage**: Table and index size with growth projections
- **Temporary File Usage**: Monitoring of disk usage for temporary operations

### Maintenance Analysis
- **Vacuum Statistics**: Frequency and effectiveness of auto-vacuum operations
- **Analyze Statistics**: Currency of statistics used by the query planner
- **Dead Tuples**: Identification of tables with high amounts of dead tuples

### Configuration Analysis
- **Parameter Settings**: Evaluation of key PostgreSQL configuration parameters
- **Work Memory**: Analysis of memory allocated for query operations
- **Maintenance Settings**: Review of auto-vacuum and maintenance settings

### Extension Monitoring
- **Installed Extensions**: List of installed extensions and versions
- **Extension-specific Metrics**: Analysis of extension performance where applicable

### WAL and Recovery
- **WAL Generation Rate**: Volume and frequency of WAL generation
- **Archive Status**: Success rate and lag of WAL archiving (if configured)

## Usage

Run the script from an EC2 instance that has network access to your PostgreSQL database:

```bash
./postgres_health_check.sh
```

You'll be prompted to enter:
1. RDS PostgreSQL instance endpoint URL
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

The HTML report is organized into sections, each focusing on a specific aspect of database health. The metrics are color-coded:
- Green: Good/Healthy
- Yellow/Orange: Warning/Attention Needed
- Red: Critical/Action Required

## Compatibility

This script works well with PostgreSQL 9.6 and newer versions, including:
- PostgreSQL 9.6
- PostgreSQL 10, 11, 12, 13, 14, 15
- AWS RDS PostgreSQL
- Aurora PostgreSQL

## Requirements

- PostgreSQL client installed on the executing machine
- AWS CLI configured (for AWS-specific features)
- Database user with read permissions on system catalogs and statistics views
