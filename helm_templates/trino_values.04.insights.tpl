coordinator:
  etcFiles:
    properties:
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_insights}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}
  additionalProperties: |
    insights.persistence-enabled=true
    insights.metrics-persistence-enabled=true
    insights.jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_insights}
    insights.jdbc.user=${primary_db_user}
    insights.jdbc.password=${primary_db_password}
    insights.authorized-users=${admin_user}
    starburst.data-product.enabled=true
    data-product.starburst-user=${admin_user}
    data-product.starburst-password=${admin_pass}
    data-product.starburst-jdbc-url=jdbc:trino://${starburst_service_prefix}.${dns_zone}:443?SSL=true

worker:
  etcFiles:
    properties:
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_insights}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}
