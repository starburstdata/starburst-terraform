coordinator:
 additionalProperties: |
    insights.persistence-enabled=true
    insights.metrics-persistence-enabled=true
    insights.jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_insights}
    insights.jdbc.user=${primary_db_user}
    insights.jdbc.password=${primary_db_password}
    starburst.data-product.enabled=true
    data-product.starburst-user=${admin_user}
    data-product.starburst-password=${admin_pass}
    data-product.starburst-jdbc-url=jdbc:trino://${starburst_service_prefix}.${dns_zone}:443?SSL=true
