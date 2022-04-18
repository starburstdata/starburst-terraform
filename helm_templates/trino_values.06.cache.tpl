coordinator:
  etcFiles:
    properties:
      cache.properties: |
        service-database.jdbc-url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_cache}
        service-database.user=${primary_db_user}
        service-database.password=${primary_db_password}
        starburst.user=${admin_user}
        starburst.jdbc-url=jdbc:trino://coordinator:8080
        rules.file=etc/cache-rules.json
        rules.refresh-period=1m
        refresh-initial-delay=2m
        refresh-interval=24h
      cache-rules.json: |
        {
        "defaultGracePeriod": "5m",
        "defaultMaxImportDuration": "5m",
        "defaultCacheCatalog": "hive",
        "defaultCacheSchema": "default",
        "defaultUnpartitionedImportConfig": {
            "usePreferredWritePartitioning": false,
            "preferredWritePartitioningMinNumberOfPartitions": 1,
            "scaleWriters": false,
            "writerMinSize": "100MB",
            "writerCount": "4"
        }

catalogs:
  hive: |
    connector.name=hive
    hive.allow-drop-table=true
    hive.metastore.uri=${hive_service_url}
    cache-service.uri=http://coordinator:8180
    materialized-views.enabled=true
    materialized-views.namespace=mv_namespace
    materialized-views.storage-schema=cache