#!/bin/bash
# **README**
#1. Copy script on Amazon EC2 Linux instance with AWS CLI configured, and mysql client installed with accessibility to RDS/Aurora MySQL instance
#2. Make script executable: chmod +x mysql_health_check.sh
#3. Run the script: ./mysql_health_check.sh
#4. Use the RDS MySQL or Aurora MySQL Primary instance endpoint URL for connection
#5. The database user should have READ access on all of the tables to get better metrics
#6. It will take around 2-3 mins to run (depending on size of instance), and generate html report: <CompanyName>_<DatabaseIdentifier>_report_<date>.html
#7. Share the report with your AWS Technical Account Manager.
#8. This script works well for MySQL 5.7 and newer versions.
#
# **FEATURES AND METRICS COVERED**
# - Database Size Analysis: Overall and per-database size metrics
# - Table Size Analysis: Identification of largest tables
# - Index Analysis: Detection of redundant and unused indexes
# - InnoDB Buffer Pool: Hit ratio and utilization metrics
# - Performance Parameters: Key MySQL configuration parameters
# - Query Analysis: Top slow queries and I/O consuming queries
# - Temporary Table Statistics: Memory vs disk-based temporary tables
# - Table Fragmentation: Identification of fragmented tables
# - Replication Health: Status, lag, and error detection
# - Connection Usage: Trends, utilization, and pooling recommendations
# - Query Cache Effectiveness: Hit ratio and performance analysis
# - Lock Contention: Identification of waiting transactions and deadlocks
# - Long-Running Transactions: Detection of transactions that may cause problems
# - Disk Space Health: Usage by schema and free space monitoring
# - User Privileges: Audit of users with elevated privileges
# - Error Log Monitoring: Extraction of recent errors and warnings
# - Resource Usage: Tracking of resource consumption by user/application
# - Configuration Drift: Comparison against best practices with recommendations
# - Aurora-specific Metrics: Specialized metrics for Aurora MySQL instances
#################
# Author: Amit Tiwari - Adapted from PostgreSQL script by Vivek Singh
# V-1 : MAY 10 2025
#################
clear
echo -n -e "RDS MySQL instance endpoint URL or Aurora MySQL Primary instance endpoint URL: "
read EP
echo -n -e "Port: "
read RDSPORT
echo -n -e "Database Name: "
read DBNAME
echo -n -e "RDS Master User Name: "
read MASTERUSER
echo -n -e "Password: "
read -s  MYPASS
echo  ""
echo -n -e "Company Name (with no space): "
read COMNAME
RDSNAME="${EP%%.*}"
html=${COMNAME}_${RDSNAME}_report_$(date +"%m-%d-%y").html

MYSQLCL="mysql -h $EP -P $RDSPORT -u $MASTERUSER -p$MYPASS $DBNAME"
MYSQLCMD="mysql -h $EP -P $RDSPORT -u $MASTERUSER -p$MYPASS -N -s $DBNAME"

# Test connection
echo "Testing connection..."
$MYSQLCMD -e "SELECT NOW()" >/dev/null 2>&1
if [ "$?" -gt "0" ]; then
  echo "Instance $EP cannot be connected. Stopping the script"
  sleep 1
  exit
else
  echo "Instance is running. Creating report..."
fi

# Determine if Aurora or RDS
if $MYSQLCMD -e "SHOW VARIABLES LIKE 'aurora_version'" | grep -q 'aurora_version'; then
  DBTYPE="aurora-mysql"
else 
  DBTYPE="mysql"
fi

# SQL Queries for the report
# Idle Connections
SQL1="SELECT COUNT(*) FROM information_schema.processlist WHERE command='Sleep';"

# Top 5 Databases Size
SQL2="SELECT table_schema AS 'DB_Name', 
      ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'DB_Size_MB',
      CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 2), ' GB') AS 'Pretty_DB_size'
      FROM information_schema.tables
      GROUP BY table_schema
      ORDER BY SUM(data_length + index_length) DESC LIMIT 5;"

# Total Size of All Databases
SQL3="SELECT 
      CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 2), ' GB') AS 'Total_DB_size'
      FROM information_schema.tables;"

# Top 10 biggest tables
SQL4="SELECT 
      table_schema AS 'table_schema',
      table_name AS 'table_name',
      CONCAT(ROUND(((data_length + index_length) / 1024 / 1024), 2), ' MB') AS 'total_size',
      CONCAT(ROUND((data_length / 1024 / 1024), 2), ' MB') AS 'data_size',
      CONCAT(ROUND((index_length / 1024 / 1024), 2), ' MB') AS 'index_size'
      FROM information_schema.tables
      WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
      ORDER BY (data_length + index_length) DESC LIMIT 10;"

# Redundant Indexes
SQL5="SELECT * FROM sys.schema_redundant_indexes ORDER BY redundant_index_name LIMIT 10;"

# Unused Indexes
SQL6="SELECT * FROM sys.schema_unused_indexes LIMIT 10;"

# InnoDB Buffer Pool Statistics
SQL7="SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';"

# Most fragmented tables
SQL8="SELECT
      table_schema AS 'Schema',
      table_name AS 'Table',
      ROUND(data_free/(data_length+index_length+data_free)*100, 2) AS 'Fragmentation_%'
      FROM information_schema.tables
      WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
      AND data_free > 0
      AND (data_length+index_length+data_free) > 0
      ORDER BY data_free/(data_length+index_length+data_free)*100 DESC LIMIT 10;"

# Top 10 biggest tables with statistics on rows
SQL9="SELECT 
      table_schema AS 'Schema',
      table_name AS 'Table', 
      table_rows AS 'Rows', 
      ROUND(data_length/1024/1024, 2) AS 'Data_MB', 
      ROUND(index_length/1024/1024, 2) AS 'Index_MB',
      CONCAT(ROUND(((data_length + index_length) / 1024 / 1024), 2), ' MB') AS 'Total_Size',
      UPDATE_TIME as 'Last_Updated'
      FROM information_schema.tables 
      WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys') 
      ORDER BY (data_length + index_length) DESC LIMIT 10;"

# Key MySQL Parameters
SQL10="SHOW GLOBAL VARIABLES WHERE Variable_name IN (
      'max_connections', 
      'innodb_buffer_pool_size', 
      'innodb_buffer_pool_instances',
      'innodb_flush_log_at_trx_commit',
      'innodb_log_file_size',
      'innodb_io_capacity',
      'innodb_read_io_threads',
      'innodb_write_io_threads',
      'max_allowed_packet',
      'table_open_cache');"

# Performance Parameters
SQL11="SHOW GLOBAL VARIABLES WHERE Variable_name IN (
       'innodb_buffer_pool_size',
       'innodb_buffer_pool_instances',
       'innodb_flush_method',
       'innodb_flush_log_at_trx_commit',
       'innodb_log_file_size',
       'innodb_read_io_threads',
       'innodb_write_io_threads',
       'max_allowed_packet',
       'table_open_cache',
       'query_cache_type');"

# Slow Query Statistics
SQL12="SELECT * FROM sys.statements_with_runtimes_in_95th_percentile LIMIT 10;"

# Top IO consuming queries
SQL13="SELECT * FROM sys.io_global_by_file_by_bytes ORDER BY total DESC LIMIT 10;"

# Top IO consuming tables
SQL14="SELECT * FROM sys.io_global_by_wait_by_bytes LIMIT 10;"

# Top UPDATE/DELETE operations by table
# Replaced sum_timer_insert + sum_timer_update + sum_timer_delete with insert_latency + update_latency  + delete_latency
SQL15="SELECT * FROM sys.schema_table_statistics 
       ORDER BY (insert_latency + update_latency  + delete_latency) DESC 
       LIMIT 10;"

# InnoDB buffer pool hit ratio
# Changed alias from reads to reads_
SQL16="SELECT 
       (SELECT variable_value FROM performance_schema.global_status WHERE variable_name='Innodb_buffer_pool_reads') AS reads_,
       (SELECT variable_value FROM performance_schema.global_status WHERE variable_name='Innodb_buffer_pool_read_requests') AS requests,
       IF((SELECT variable_value FROM performance_schema.global_status WHERE variable_name='Innodb_buffer_pool_read_requests') > 0,
          ROUND(100 - ((SELECT variable_value FROM performance_schema.global_status WHERE variable_name='Innodb_buffer_pool_reads') / 
                       (SELECT variable_value FROM performance_schema.global_status WHERE variable_name='Innodb_buffer_pool_read_requests') * 100), 2),
          0) AS hit_ratio;"

# Logging parameters
SQL17="SHOW GLOBAL VARIABLES WHERE Variable_name IN (
       'general_log',
       'log_output',
       'slow_query_log',
       'slow_query_log_file',
       'long_query_time');"

# Aurora specific parameters (if applicable)
SQL18="SHOW GLOBAL VARIABLES WHERE Variable_name LIKE '%aurora%';"

# Temporary table statistics
SQL20="SHOW GLOBAL STATUS LIKE 'Created_tmp%';"

# Query Execution Plan Analysis for top slow queries
SQL21="SELECT query_sample_text AS query, count_star, sum_timer_wait/1000000000 as time_ms 
FROM performance_schema.events_statements_summary_by_digest 
WHERE schema_name NOT IN ('mysql', 'performance_schema', 'information_schema', 'sys') 
ORDER BY sum_timer_wait DESC LIMIT 5;"

# Replication Health
SQL22="SHOW SLAVE STATUS\G"

# Connection Usage Trends
SQL23="SELECT VARIABLE_VALUE AS max_connections FROM performance_schema.global_variables WHERE VARIABLE_NAME='max_connections';"
SQL24="SHOW STATUS WHERE Variable_name IN ('Threads_connected', 'Max_used_connections', 'Connections', 'Aborted_connects', 'Aborted_clients');"

# Query Cache Effectiveness (if enabled)
SQL25="SHOW GLOBAL STATUS LIKE 'Qcache%';"
SQL26="SHOW GLOBAL VARIABLES LIKE 'query_cache%';"

# Lock Contention and Waits
# Changed count to count(*), do we need group by?
SQL27="SELECT count(*) AS waiting_transactions, wait_age_secs, locked_table, locked_type, waiting_query 
FROM sys.innodb_lock_waits 
ORDER BY wait_age_secs DESC;"
SQL28="SHOW ENGINE INNODB STATUS\G"

# Long-Running Transactions
SQL29="SELECT trx_id, trx_state, trx_started, TIME_TO_SEC(TIMEDIFF(NOW(), trx_started)) AS duration_secs, 
TRUNCATE(trx_rows_locked/1000,0) AS rows_locked_thousands, 
TRUNCATE(trx_rows_modified/1000,0) AS rows_modified_thousands, 
trx_mysql_thread_id AS thread_id 
FROM information_schema.innodb_trx 
WHERE TIME_TO_SEC(TIMEDIFF(NOW(), trx_started)) > 60 
ORDER BY trx_started;"

# Disk Space and Filesystem Health
SQL30="SELECT table_schema, 
ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 2) AS 'Size (GB)', 
COUNT(*) AS 'Tables', 
ROUND(SUM(data_free) / 1024 / 1024 / 1024, 2) AS 'Free Space (GB)' 
FROM information_schema.tables 
GROUP BY table_schema;"

# User Privileges Audit
SQL31="SELECT user, host, Super_priv, Grant_priv, File_priv, Shutdown_priv, Process_priv, Reload_priv 
FROM mysql.user WHERE Super_priv = 'Y' OR Grant_priv = 'Y';"

# Error Log and Warning Monitoring
SQL32="SHOW GLOBAL VARIABLES LIKE 'log_error';"

# Resource Usage by User/Application
SQL33="SELECT user, host, current_connections, total_connections, 
connected_time, busy_time, cpu_time, bytes_received, bytes_sent 
FROM performance_schema.accounts 
WHERE current_connections > 0 
ORDER BY current_connections DESC, busy_time DESC;"

# Configuration Drift Detection (Top important configurations)
SQL34="SHOW GLOBAL VARIABLES WHERE Variable_name IN (
'innodb_buffer_pool_size', 'max_connections', 'query_cache_size',
'tmp_table_size', 'max_heap_table_size', 'sort_buffer_size',
'read_buffer_size', 'read_rnd_buffer_size', 'join_buffer_size',
'thread_cache_size', 'open_files_limit', 'table_open_cache');"
# --- HTML Report Generation ---

# Section: Database Sizes
# Fixed query execution
echo "<font face=\"verdana\" color=\"#ff6600\">Total Size of All Databases:</font> " >>$html
$MYSQLCL -H -e "$SQL3" >>$html
echo "<br>" >> $html
echo "<br>" >> $html

TOTALDB=$($MYSQLCMD -e "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');")
echo "<font face=\"verdana\" color=\"#ff6600\">Top 5 Databases Size ($TOTALDB):</font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL2" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Biggest Tables
TOTALTAB=$($MYSQLCMD -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys') AND table_type='BASE TABLE';")
echo "<font face=\"verdana\" color=\"#ff6600\">Top 10 Biggest Tables ($TOTALTAB): </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL4" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: Consider partitioning large tables for improved query performance and easier data management.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Redundant Indexes
echo "<font face=\"verdana\" color=\"#ff6600\">Redundant Indexes: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL5" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: Drop redundant indexes to save space and improve write performance.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Unused Indexes
echo "<font face=\"verdana\" color=\"#ff6600\">Unused Indexes: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL6" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: Drop unused indexes to save space and improve write performance.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Table Fragmentation
echo "<font face=\"verdana\" color=\"#ff6600\">Table Fragmentation: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL8" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: Consider optimizing tables with high fragmentation.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: InnoDB Buffer Pool Stats
echo "<font face=\"verdana\" color=\"#ff6600\">InnoDB Buffer Pool Statistics: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL7" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Key MySQL Parameters
echo "<font face=\"verdana\" color=\"#ff6600\">Key MySQL Parameters: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL10" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Performance Parameters
echo "<font face=\"verdana\" color=\"#ff6600\">Performance Parameters: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL11" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Logging Parameters
echo "<font face=\"verdana\" color=\"#ff6600\">Logging Parameters: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL17" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: InnoDB Buffer Pool Hit Ratio
echo "<font face=\"verdana\" color=\"#ff6600\">InnoDB Buffer Pool Hit Ratio: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL16" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: A high hit ratio (>95%) indicates good buffer pool utilization. Lower ratios may indicate your buffer pool size is too small.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Temporary Table Statistics
echo "<font face=\"verdana\" color=\"#ff6600\">Temporary Table Statistics: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL20" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: High numbers of disk temporary tables may indicate you need to increase your tmp_table_size and max_heap_table_size.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Top Slow Queries
echo "<font face=\"verdana\" color=\"#ff6600\">Top 10 Slow Queries (95th percentile): </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL12" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Top IO Consuming Queries
echo "<font face=\"verdana\" color=\"#ff6600\">Top IO Consuming Queries: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL13" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Top IO Consuming Tables
echo "<font face=\"verdana\" color=\"#ff6600\">Top IO Consuming Tables: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL14" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Top UPDATE/DELETE Tables
echo "<font face=\"verdana\" color=\"#ff6600\">Top UPDATE/DELETE Tables: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL15" >>$html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Aurora-specific Parameters
if [[ "$DBTYPE" == "aurora-mysql" ]]; then
  echo "<font face=\"verdana\" color=\"#ff6600\">Aurora-specific Parameters: </font>" >>$html
  echo "<br>" >> $html
  $MYSQLCL -H -e "$SQL18" >>$html
  echo "<br>" >> $html
  echo "<br>" >> $html
fi

# Section: Query Execution Plan Analysis
echo "<font face=\"verdana\" color=\"#ff6600\">Query Execution Plan Analysis (Top Slow Queries): </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL21" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: Run EXPLAIN on these queries in your application to identify optimization opportunities.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Replication Health
if $MYSQLCMD -e "SHOW SLAVE STATUS" 2>/dev/null | grep -q 'Slave_IO_Running'; then
  echo "<font face=\"verdana\" color=\"#ff6600\">Replication Health: </font>" >>$html
  echo "<br>" >> $html
  REPL_RESULTS=$($MYSQLCMD -e "$SQL22")
  echo "<pre>$REPL_RESULTS</pre>" >>$html
  IO_RUNNING=$(echo "$REPL_RESULTS" | grep 'Slave_IO_Running:' | awk '{print $2}')
  SQL_RUNNING=$(echo "$REPL_RESULTS" | grep 'Slave_SQL_Running:' | awk '{print $2}')
  SECONDS_BEHIND=$(echo "$REPL_RESULTS" | grep 'Seconds_Behind_Master:' | awk '{print $2}')
  
  if [[ "$IO_RUNNING" == "Yes" && "$SQL_RUNNING" == "Yes" ]]; then
    echo "<font face=\"verdana\" color=\"#009900\">Replication Status: Healthy</font>" >> $html
  else
    echo "<font face=\"verdana\" color=\"#ff0000\">Replication Status: Unhealthy</font>" >> $html
  fi
  
  if [[ "$SECONDS_BEHIND" == "NULL" || "$SECONDS_BEHIND" -gt 300 ]]; then
    echo "<font face=\"verdana\" color=\"#ff0000\">Replication Lag: $SECONDS_BEHIND seconds</font>" >> $html
  elif [[ "$SECONDS_BEHIND" -gt 60 ]]; then
    echo "<font face=\"verdana\" color=\"#ff6600\">Replication Lag: $SECONDS_BEHIND seconds</font>" >> $html
  else
    echo "<font face=\"verdana\" color=\"#009900\">Replication Lag: $SECONDS_BEHIND seconds</font>" >> $html
  fi
  
  echo "<br>" >> $html
  echo "<br>" >> $html
fi

# Section: Connection Usage Trends
echo "<font face=\"verdana\" color=\"#ff6600\">Connection Usage: </font>" >>$html
echo "<br>" >> $html
MAX_CONN=$($MYSQLCMD -e "$SQL23")
CONN_STATS=$($MYSQLCMD -e "$SQL24")
CURR_CONN=$(echo "$CONN_STATS" | grep 'Threads_connected' | awk '{print $2}')
MAX_USED=$(echo "$CONN_STATS" | grep 'Max_used_connections' | awk '{print $2}')
PCT_USED=$((100*MAX_USED/MAX_CONN))

echo "<table border='1'>" >> $html
echo "<tr><th>Metric</th><th>Value</th></tr>" >> $html
echo "<tr><td>Max Allowed Connections</td><td>$MAX_CONN</td></tr>" >> $html
echo "<tr><td>Current Connections</td><td>$CURR_CONN</td></tr>" >> $html
echo "<tr><td>Max Used Connections</td><td>$MAX_USED</td></tr>" >> $html
echo "<tr><td>Max Connection Utilization</td><td>$PCT_USED%</td></tr>" >> $html
echo "</table>" >> $html

if [[ $PCT_USED -gt 80 ]]; then
  echo "<font face=\"verdana\" color=\"#ff0000\">Warning: Max connection usage is high ($PCT_USED%). Consider increasing max_connections or optimizing application connection pooling.</font>" >> $html
fi

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Query Cache Effectiveness
QC_SIZE=$($MYSQLCMD -e "$SQL26" | grep 'query_cache_size' | awk '{print $2}')

if [[ "$QC_SIZE" != "0" ]]; then
  echo "<font face=\"verdana\" color=\"#ff6600\">Query Cache Effectiveness: </font>" >>$html
  echo "<br>" >> $html
  $MYSQLCL -H -e "$SQL25" >>$html
  $MYSQLCL -H -e "$SQL26" >>$html
  
  QC_HITS=$($MYSQLCMD -e "SHOW GLOBAL STATUS LIKE 'Qcache_hits'" | awk '{print $2}')
  QC_INSERTS=$($MYSQLCMD -e "SHOW GLOBAL STATUS LIKE 'Qcache_inserts'" | awk '{print $2}')
  
  # Check if these variables are integers
  if [[ "$QC_HITS" =~ ^[0-9]+$ ]] && [[ "$QC_INSERTS" =~ ^[0-9]+$ ]]; then
    if [[ "$QC_HITS" != "0" && "$QC_INSERTS" != "0" ]]; then
      HIT_RATIO=$((QC_HITS*100/(QC_HITS+QC_INSERTS)))
      echo "<font face=\"verdana\" color=\"#0099cc\">Query Cache Hit Ratio: $HIT_RATIO%</font>" >> $html
    
      if [[ $HIT_RATIO -lt 20 ]]; then
        echo "<font face=\"verdana\" color=\"#ff0000\">Warning: Low query cache hit ratio. Consider disabling query cache or tuning its size.</font>" >> $html
      fi
    fi
  else
    echo "<font face=\"verdana\" color=\"#ff0000\">Error: Qcache_hits or Qcache_inserts is not an integer.</font>" >> "$html"
  fi
  
  echo "<br>" >> $html
  echo "<br>" >> $html
fi

# Section: Lock Contention and Waits
echo "<font face=\"verdana\" color=\"#ff6600\">Lock Contention and Waits: </font>" >>$html
echo "<br>" >> $html

# Check if sys schema is available
SYS_SCHEMA=$($MYSQLCMD -e "SHOW DATABASES LIKE 'sys'")
if [[ -n "$SYS_SCHEMA" ]]; then
  $MYSQLCL -H -e "$SQL27" >>$html
else
  echo "<font face=\"verdana\" color=\"#ff0000\">Note: The 'sys' schema is not available. Install it for better lock analysis.</font>" >> $html
fi

LOCK_INFO=$($MYSQLCMD -e "$SQL28" | grep -E 'TRANSACTIONS|waiting for this lock to be granted|ROLLING BACK')
if [[ -n "$LOCK_INFO" ]]; then
  echo "<pre>$LOCK_INFO</pre>" >>$html
else
  echo "<font face=\"verdana\" color=\"#009900\">No significant lock contention detected.</font>" >> $html
fi

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Long-Running Transactions
echo "<font face=\"verdana\" color=\"#ff6600\">Long-Running Transactions (>60 seconds): </font>" >>$html
echo "<br>" >> $html
LONG_TRX=$($MYSQLCMD -e "$SQL29")

if [[ -n "$LONG_TRX" ]]; then
  $MYSQLCL -H -e "$SQL29" >>$html
  echo "<font face=\"verdana\" color=\"#ff0000\">Warning: Long-running transactions detected. These can cause increased undo space usage and block purge operations.</font>" >> $html
else
  echo "<font face=\"verdana\" color=\"#009900\">No long-running transactions detected.</font>" >> $html
fi

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Disk Space and Filesystem Health
echo "<font face=\"verdana\" color=\"#ff6600\">Disk Space Usage by Schema: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL30" >>$html

# If AWS, get the free disk space from the instance
if command -v aws &> /dev/null; then
  # Get instance ID from metadata service
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  if [[ -n "$INSTANCE_ID" ]]; then
    AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
    DISK_METRICS=$(aws cloudwatch get-metric-statistics --namespace AWS/RDS --metric-name FreeStorageSpace --dimensions Name=DBInstanceIdentifier,Value=$DBHOST --start-time $(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --period 3600 --statistics Minimum --region $AWS_REGION 2>/dev/null)
    
    if [[ -n "$DISK_METRICS" ]]; then
      FREE_SPACE=$(echo "$DISK_METRICS" | grep -o '"Minimum":[0-9.]*' | cut -d':' -f2 | sort -n | head -1)
      FREE_SPACE_GB=$(echo "scale=2; $FREE_SPACE/1024/1024/1024" | bc)
      echo "<font face=\"verdana\" color=\"#0099cc\">Free Storage Space: $FREE_SPACE_GB GB</font>" >> $html
      
      if (( $(echo "$FREE_SPACE_GB < 10" | bc -l) )); then
        echo "<font face=\"verdana\" color=\"#ff0000\">Warning: Low free disk space. Consider cleaning up data or increasing storage.</font>" >> $html
      fi
    fi
  fi
fi

echo "<br>" >> $html
echo "<br>" >> $html

# Section: User Privileges Audit
echo "<font face=\"verdana\" color=\"#ff6600\">Users with Admin Privileges: </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL31" >>$html
echo "<font face=\"verdana\" color=\"#0099cc\">Note: Review these users and ensure they follow the principle of least privilege.</font>" >> $html

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Error Log Monitoring
echo "<font face=\"verdana\" color=\"#ff6600\">Recent Error Log Entries: </font>" >>$html
echo "<br>" >> $html
LOG_FILE=$($MYSQLCMD -e "$SQL32" | awk '{print $2}')

if [[ -n "$LOG_FILE" && -r "$LOG_FILE" ]]; then
  # Extract the last 20 lines containing errors
  ERROR_LOGS=$(tail -1000 "$LOG_FILE" | grep -i 'error\|warn' | tail -20)
  echo "<pre>$ERROR_LOGS</pre>" >>$html
else
  echo "<font face=\"verdana\" color=\"#0099cc\">Error log file not accessible from this host.</font>" >> $html
fi

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Resource Usage by User/Application
echo "<font face=\"verdana\" color=\"#ff6600\">Resource Usage by User/Application: </font>" >>$html
echo "<br>" >> $html
PS_ENABLED=$($MYSQLCMD -e "SHOW VARIABLES LIKE 'performance_schema'" | grep 'performance_schema' | awk '{print $2}')

if [[ "$PS_ENABLED" == "ON" ]]; then
  $MYSQLCL -H -e "$SQL33" >>$html
else
  echo "<font face=\"verdana\" color=\"#ff0000\">Performance Schema is not enabled. Enable it for better user/application resource tracking.</font>" >> $html
fi

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Configuration Drift Detection
echo "<font face=\"verdana\" color=\"#ff6600\">Configuration Drift Detection (Important Parameters): </font>" >>$html
echo "<br>" >> $html
$MYSQLCL -H -e "$SQL34" >>$html

# Compare to best practices
BP_BUFFER_POOL_SIZE=$(($(grep MemTotal /proc/meminfo | awk '{print $2}') * 70 / 100))
CURR_BUFFER_POOL_SIZE=$($MYSQLCMD -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size'" | awk '{print $2}')

if [[ $CURR_BUFFER_POOL_SIZE -lt $BP_BUFFER_POOL_SIZE ]]; then
  echo "<font face=\"verdana\" color=\"#ff6600\">Buffer pool size might be too small. Recommended: $BP_BUFFER_POOL_SIZE bytes (70% of system memory)</font>" >> $html
fi

echo "<br>" >> $html
echo "<br>" >> $html

# Section: Recommendations
echo "<font face=\"verdana\" color=\"#0099cc\"><b>Recommendations and Notes:</b></font>" >> $html
echo "<br>" >> $html
echo "<ul>" >> $html
echo "<li>Set up CloudWatch alarms for key metrics like CPU, memory, disk usage and replica lag.</li>" >> $html
echo "<li>Implement parameter group changes based on the health score.</li>" >> $html
echo "<li>Regularly monitor and optimize slow queries.</li>" >> $html
echo "<li>Implement a routine maintenance schedule for table optimization.</li>" >> $html
echo "<li>Ensure regular backups and test restoration procedures.</li>" >> $html
echo "<li>Review long-running transactions and optimize them to reduce lock contention.</li>" >> $html
echo "<li>Audit user privileges regularly to ensure principle of least privilege.</li>" >> $html
echo "<li>Monitor disk space usage and set up alerts for low disk space.</li>" >> $html
echo "<li>Check replication lag regularly if using replicas.</li>" >> $html
echo "<li>Consider implementing connection pooling if connection usage is high.</li>" >> $html
if [[ "$DBTYPE" == "aurora-mysql" ]]; then
  echo "<li>For Aurora MySQL, leverage fast cloning and backtracking capabilities for testing.</li>" >> $html
fi
echo "</ul>" >> $html

echo "</body>" >> $html
echo "</html>" >> $html

echo "Report generated: $html"
echo "Done!"