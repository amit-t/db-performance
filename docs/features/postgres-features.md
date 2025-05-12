# PostgreSQL Health Check Features

This page provides detailed information about each feature of the PostgreSQL Health Check script.

## Database Size Analysis

### Overall Database Size
The script provides the total size of all databases on the instance, giving you a clear overview of storage consumption.

### Per-Database Size
Lists the top 5 largest databases with their sizes, helping you identify which databases are using the most space.

## Table Size Analysis

### Largest Tables
Identifies the top 10 largest tables across all databases, showing both table size and index size separately.

### Table Growth Monitoring
Where historical data is available, shows growth trends for tables.

## Bloat Analysis

### Table Bloat
Detects tables with significant bloat (space that could be reclaimed with VACUUM).

### Index Bloat
Identifies indexes with excessive bloat that impact both storage and query performance.

### Bloat Ratios
Calculates the percentage of space that could be reclaimed through proper maintenance.

## Buffer Cache Analysis

### Hit Ratio
Measures the percentage of data blocks found in the buffer cache vs. those that needed to be read from disk.

### Cache Effectiveness
Evaluates how effectively your buffer cache is sized for your workload.

## Query Analysis

### Long-Running Queries
Lists queries with the longest execution times.

### Frequently Run Queries
Identifies the most commonly executed queries that might benefit from optimization.

### Pattern Analysis
Detects query patterns that could indicate inefficient application design.

## Index Usage Analysis

### Unused Indexes
Identifies indexes that are not being used in queries but still consume storage and impact write performance.

### Missing Indexes
Suggests potential indexes based on query patterns and sequential scan frequency.

### Index vs. Sequential Scans
Analyzes the ratio of index scans to sequential scans for each table.

## Vacuum and Analyze Statistics

### Auto-vacuum Activity
Monitors the frequency and effectiveness of auto-vacuum operations.

### Dead Tuple Accumulation
Identifies tables with high numbers of dead tuples that need cleaning.

### Statistics Currency
Checks when table statistics were last updated and identifies stale statistics that might affect query planning.

## Transaction Wrap-around Protection

### Transaction ID Consumption
Monitors the rate of transaction ID consumption.

### Wrap-around Risk
Calculates the risk of transaction ID wrap-around and the time before preventive actions are needed.

## Connection Usage

### Connection Patterns
Analyzes connection usage patterns over time.

### Idle Connections
Identifies idle connections that might be wasting resources.

### Connection Limits
Compares current usage against configured limits.

## Checkpoint Activity

### Checkpoint Frequency
Monitors how often checkpoints occur.

### Write Impact
Analyzes the I/O impact of checkpoints on system performance.

### Tuning Recommendations
Provides recommendations for checkpoint-related parameters.

## WAL Analysis

### WAL Generation Rate
Calculates the rate at which Write-Ahead Log files are being generated.

### Archive Status
For instances with WAL archiving enabled, checks archive success rate and lag.

## Sequence Usage

### High-Volume Sequences
Identifies sequences with high usage rates.

### Exhaustion Risk
For 32-bit sequences, calculates risk of exhaustion.

## Extension Monitoring

### Installed Extensions
Lists all installed extensions with their versions.

### Extension-specific Metrics
Where applicable, provides metrics specific to extensions like PostGIS, pg_stat_statements, etc.

## Parameter Settings Analysis

### Configuration Review
Evaluates key PostgreSQL configuration parameters against best practices.

### Memory Allocation
Analyzes memory allocation across different PostgreSQL components.

### Parallelism Settings
Reviews parallel query settings and their appropriateness for your hardware.

## Temporary File Usage

### Temp File Creation
Monitors operations that spill to temporary files.

### Sort/Hash Memory
Analyzes if work_mem settings are appropriate based on temporary file usage.

## Lock Analysis

### Lock Contention
Identifies sessions waiting for locks and the sessions holding those locks.

### Deadlock Patterns
Detects recurring deadlock situations that might indicate application issues.

## Statement Statistics

### Cache Hit Ratio
For instances with pg_stat_statements enabled, analyzes statement cache hit ratio.

### Plan vs. Execute Time
Breaks down query time between planning and execution phases.

## Replica Status

### Replication Lag
For replicas, measures and alerts on replication lag.

### Apply vs. Network Lag
Distinguishes between network transfer lag and replay lag.

## Index Recommendations

### Index Consolidation Opportunities
Suggests where multiple indexes could be consolidated.

### Unused Index Analysis
Provides detailed analysis of why certain indexes remain unused.

## Disk I/O Analysis

### Table I/O Patterns
Shows which tables have the highest read and write activity.

### Index I/O Efficiency
Analyzes the I/O efficiency of indexes in relation to their usage.

## RDS-Specific Features

### Parameter Group Analysis
For RDS instances, reviews parameter group settings.

### CloudWatch Metric Integration
Incorporates relevant CloudWatch metrics into the analysis.

## Aurora-Specific Features

### Aurora Storage
For Aurora PostgreSQL, analyzes Aurora-specific storage metrics.

### Instance Type Recommendations
Suggests optimal Aurora instance types based on your workload patterns.
