```sh
#!/bin/sh
set -eu

cat > "$PGDATA/pg_hba.conf" <<'EOF'
# Conexiones locales
local   all             all                                     scram-sha-256
host    all             all             127.0.0.1/32            scram-sha-256

# Conexiones desde otros contenedores de la red Docker
host    all             all             samenet                 scram-sha-256

# Permitir replicación al usuario replicador
host    replication     replicador      samenet                 scram-sha-256
EOF
```