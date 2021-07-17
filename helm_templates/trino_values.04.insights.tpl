coordinator:
  etcFiles:
    properties:
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}
  additionalProperties: |
    insights.persistence-enabled=true
    insights.metrics-persistence-enabled=true
    insights.jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
    insights.jdbc.user=${primary_db_user}
    insights.jdbc.password=${primary_db_password}
    insights.authorized-users=^sa.*|${admin_user}

worker:
  etcFiles:
    properties:
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}
