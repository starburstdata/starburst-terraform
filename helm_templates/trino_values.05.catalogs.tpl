catalogs:
  tpcds: |
    connector.name=tpcds
  jmx: |
    connector.name=jmx
  postgres: |
    connector.name=postgresql
    connection-url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${demo_db_name}
    connection-user=${primary_db_user}
    connection-password=${primary_db_password}
  hive: |
    connector.name=hive-hadoop2
    hive.allow-drop-table=true
    hive.metastore.uri=${hive_service_url}

