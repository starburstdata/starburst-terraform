coordinator:
  etcFiles:
    properties:
      config.properties: |
        coordinator=true
        node-scheduler.include-coordinator=false
        http-server.http.port=8080
        discovery-server.enabled=true
        discovery.uri=http://localhost:8080
        usage-metrics.cluster-usage-resource.enabled=true
        http-server.authentication.allow-insecure-over-http=true
        web-ui.enabled=true
        http-server.process-forwarded=true
        insights.persistence-enabled=true
        insights.metrics-persistence-enabled=true
        insights.jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        insights.jdbc.user=${primary_db_user}
        insights.jdbc.password=${primary_db_password}
        insights.authorized-users=${admin_user}
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}

worker:
  etcFiles:
    properties:
      event-listener.properties: |
        event-listener.name=event-logger
        jdbc.url=jdbc:postgresql://${primary_ip_address}:${primary_db_port}/${primary_db_event_logger}
        jdbc.user=${primary_db_user}
        jdbc.password=${primary_db_password}
