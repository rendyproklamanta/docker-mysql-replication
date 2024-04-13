mysql -uadmin -padmin -P 6032
SELECT * from mysql_replication_hostgroups;
SELECT * FROM mysql_servers;
SELECT * FROM mysql_users;
SELECT rule_id, match_digest, match_pattern, replace_pattern, cache_ttl, apply FROM mysql_query_rules ORDER BY rule_id;
SELECT hostgroup hg, sum_time, count_star, digest_text FROM stats_mysql_query_digest ORDER BY sum_time DESC;
SELECT hostgroup hg, SUM(sum_time), SUM(count_star) FROM stats_mysql_query_digest GROUP BY hostgroup;