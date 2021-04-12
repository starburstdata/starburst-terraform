userDatabase:
  enabled: true
  users:
    - username: ${admin_user}
      password: ${admin_pass}
    - username: ${reg_user1}
      password: ${reg_pass1}
    - username: ${reg_user2}
      password: ${reg_pass2}

coordinator:
  etcFiles:
    properties:
      password-authenticator.properties: |
        password-authenticator.name=file
