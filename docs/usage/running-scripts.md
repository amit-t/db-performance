# Running Scripts

This guide covers how to execute the database health check scripts and collect performance data from your MySQL or PostgreSQL databases.

## Prerequisites

Before running the scripts, ensure:

1. You have completed the [installation steps](installation.md)
2. You have network access to your target database
3. You have appropriate database credentials
4. For AWS RDS instances, your AWS CLI is configured correctly

## Running the MySQL Health Check

### Basic Usage

1. Navigate to the MySQL scripts directory:

```bash
cd /path/to/db-performance/mysql/scripts
```

2. Run the script:

```bash
./mysql_health_check.sh
```

3. Enter the requested information when prompted:
   - RDS MySQL instance endpoint URL or Aurora MySQL Primary instance endpoint URL
   - Port (typically 3306)
   - Database name
   - RDS Master User Name
   - Password (input will be hidden)
   - Company Name (with no spaces)

### Example Session

```
RDS MySQL instance endpoint URL or Aurora MySQL Primary instance endpoint URL: mydb.cluster-xyz123.us-east-1.rds.amazonaws.com
Port: 3306
Database Name: mydb
RDS Master User Name: admin
Password: 
Company Name (with no space): Acme
```

## Running the PostgreSQL Health Check

### Basic Usage

1. Navigate to the PostgreSQL scripts directory:

```bash
cd /path/to/db-performance/postgres/scripts
```

2. Run the script:

```bash
./postgres_health_check.sh
```

3. Enter the requested information when prompted:
   - RDS PostgreSQL instance endpoint URL
   - Port (typically 5432)
   - Database name
   - RDS Master User Name
   - Password (input will be hidden)
   - Company Name (with no spaces)

## Output Location

After successful execution, the script will generate an HTML report file:

```
<CompanyName>_<DatabaseIdentifier>_report_<date>.html
```

For example:
```
Acme_mydb_report_05-10-25.html
```

The report file will be created in the same directory where you ran the script.

## Scheduling Regular Runs

For ongoing performance monitoring, consider scheduling regular runs using cron:

1. Open your crontab:

```bash
crontab -e
```

2. Add an entry to run weekly (adjust path as needed):

```
# Run MySQL health check every Monday at 3 AM
0 3 * * 1 /path/to/db-performance/mysql/scripts/mysql_health_check.sh < /path/to/input_file.txt > /path/to/logs/mysql_health_$(date +\%Y\%m\%d).log 2>&1
```

3. Create an input file with answers to the prompts:

```
mydb.cluster-xyz123.us-east-1.rds.amazonaws.com
3306
mydb
admin
password
Acme
```

!!! warning "Security Consideration"
    Storing database credentials in a plain text file is not recommended for production environments. Consider using AWS Secrets Manager or a similar solution for better security.

## Running for Multiple Databases

If you need to monitor multiple databases, you can:

1. Create separate input files for each database
2. Set up separate cron jobs for each database
3. Use a wrapper script to iterate through multiple databases

## Troubleshooting

### Script Fails to Connect to Database

Check:
- Database endpoint is correct
- Port is correct
- Credentials are correct
- Network connectivity (security groups, VPC settings)

### Insufficient Permissions

If you see errors about insufficient privileges:
- Ensure the user has SELECT permissions on system tables
- For MySQL: Grant access to `performance_schema`, `information_schema`, and `mysql` databases
- For PostgreSQL: Grant access to system catalogs and statistics views

### Report Not Generated

Check:
- Disk space is sufficient
- You have write permissions in the directory
- Script executed completely without errors

## Next Steps

After running the script successfully, learn how to interpret the results by visiting [Interpreting Results](interpreting-results.md).
