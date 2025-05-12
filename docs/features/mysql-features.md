# MySQL Health Check Features

This page provides detailed information about each feature of the MySQL Health Check script.

## Database Size Analysis

### Overall Database Size
The script measures the total size of all databases on the instance, providing a clear picture of storage usage.

### Per-Database Size
Identifies the top 5 largest databases and their respective sizes, helping you pinpoint which databases are consuming the most storage.

## Table Size Analysis

### Largest Tables
Lists the top 10 largest tables across all databases, showing both data and index sizes.

### Growth Patterns 
Where possible, the script calculates growth trends for larger tables.

## Index Analysis

### Redundant Indexes
Identifies indexes that provide similar functionality to other existing indexes, which can be safely dropped to improve write performance and save space.

### Unused Indexes
Detects indexes that are not being used in queries but still consume storage and slow down write operations.

## InnoDB Buffer Pool Analysis

### Hit Ratio
Measures the percentage of requests served from the buffer pool versus disk reads, with recommendations for optimal buffer pool sizing.

### Buffer Pool Utilization
Analyzes how effectively the buffer pool memory is being utilized and whether adjustments are needed.

## Performance Parameters

### Key MySQL Configuration
Evaluates critical configuration parameters that affect performance, such as:
- `innodb_buffer_pool_size`
- `max_connections`
- `query_cache_size` (if enabled)
- `tmp_table_size`
- `sort_buffer_size`

### Optimal Settings
Provides recommendations based on best practices and your specific workload patterns.

## Query Analysis

### Slow Queries
Identifies the top 10 slowest queries that exceed the 95th percentile execution time.

### I/O Consuming Queries
Lists queries that perform excessive disk I/O operations.

### Execution Plan Analysis
For slow queries, provides guidance on how to analyze execution plans to identify optimization opportunities.

## Temporary Table Statistics

### Memory vs. Disk Tables
Analyzes the ratio of temporary tables created in memory versus those created on disk.

### Configuration Recommendations
Suggests optimal `tmp_table_size` and `max_heap_table_size` settings based on your workload.

## Table Fragmentation

### Fragmentation Detection
Identifies tables with significant fragmentation that may benefit from optimization.

### Optimization Recommendations
Provides guidance on when and how to optimize fragmented tables.

## Replication Health

### Status Monitoring
Checks if replication is running properly with both IO and SQL threads active.

### Lag Detection
Measures replication lag with color-coded warnings at different thresholds:
- Green: < 60 seconds
- Yellow: 60-300 seconds
- Red: > 300 seconds

### Error Identification
Detects common replication errors and provides remediation suggestions.

## Connection Usage Trends

### Current vs. Maximum
Compares current connection count against configured maximum.

### Utilization Metrics
Calculates the percentage of maximum connections used historically.

### Pooling Recommendations
Provides recommendations for connection pooling when usage patterns suggest it would be beneficial.

## Query Cache Effectiveness

### Hit Ratio Analysis
When query cache is enabled, analyzes hit ratio to determine effectiveness.

### Size Recommendations
Suggests optimal query cache size or recommends disabling it when hit ratio is poor.

## Lock Contention and Waits

### Waiting Transactions
Identifies transactions waiting for locks and the transactions holding those locks.

### Deadlock Analysis
Detects deadlock patterns and provides guidance on prevention.

### Long Lock Waits
Highlights transactions waiting for locks for excessive periods.

## Long-Running Transactions

### Detection
Finds transactions running longer than 60 seconds.

### Impact Analysis
Assesses the impact of long-running transactions on undo space usage and purge operations.

## Disk Space Health

### Schema-Level Usage
Shows disk usage broken down by schema.

### Free Space Monitoring
Monitors available free space with alerts when below thresholds.

### AWS CloudWatch Integration
For AWS instances, leverages CloudWatch metrics for enhanced storage monitoring.

## User Privileges Audit

### Admin Access Review
Lists users with elevated privileges like SUPER, GRANT, FILE, etc.

### Security Recommendations
Provides recommendations following the principle of least privilege.

## Error Log Monitoring

### Recent Errors and Warnings
Extracts recent errors and warnings from the MySQL error log.

### Pattern Identification
Identifies recurring error patterns that might indicate underlying issues.

## Resource Usage by User/Application

### Per-User Statistics
Tracks connections, CPU time, and I/O usage by user or application.

### "Noisy Neighbor" Detection
Identifies users or applications consuming disproportionate resources.

## Configuration Drift Detection

### Best Practice Comparison
Compares your configuration against established best practices.

### Optimization Opportunities
Identifies settings that deviate significantly from recommended values.

## Aurora-specific Metrics

### Aurora-Optimized Features
For Aurora MySQL instances, provides metrics on Aurora-specific optimizations.

### Instance-Type Recommendations
Suggests optimal Aurora instance types based on your workload patterns.
