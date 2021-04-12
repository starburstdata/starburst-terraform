coordinator:
  etcFiles:
    properties:
      access-control.properties: |
        access-control.name=ranger
        ranger.authentication-type=BASIC
        ranger.policy-rest-url=http://${expose_ranger_name}:6080
        ranger.service-name=starburst-enterprise
        ranger.presto-plugin-username=${admin_user}
        ranger.presto-plugin-password=${admin_pass}
        ranger.policy-refresh-interval=10s

worker:
  etcFiles:
    properties:
      access-control.properties: |
        access-control.name=ranger
        ranger.authentication-type=BASIC
        ranger.policy-rest-url=http://${expose_ranger_name}:6080
        ranger.service-name=starburst-enterprise
        ranger.presto-plugin-username=${admin_user}
        ranger.presto-plugin-password=${admin_pass}
        ranger.policy-refresh-interval=10s
