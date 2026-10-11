
#!/bin/sh
set -eu

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
REPLICATION_PASSWORD="${REPLICATION_PASSWORD:?Falta REPLICATION_PASSWORD}"

# Si todavía no hay una base inicializada, copiar db1.
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Esperando a db1..."

    until pg_isready -h db1 -p 5432 -U replicador -d mi_app1; do
        sleep 2
    done

    # No sobrescribir datos inesperados.
    if [ -n "$(find "$PGDATA" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
        echo "ERROR: PGDATA no está vacío y no contiene PG_VERSION."
        exit 1
    fi

    echo "Copiando db1 con pg_basebackup..."
    chown postgres:postgres "$PGDATA"

    gosu postgres env PGPASSWORD="$REPLICATION_PASSWORD" \
        pg_basebackup \
        -d "host=db1 port=5432 user=replicador password=$REPLICATION_PASSWORD dbname=mi_app1" \
        -D "$PGDATA" \
        -Fp -Xs -P -R

    echo "Copia terminada. db2 arrancará como standby."
fi

exec /usr/local/bin/docker-entrypoint.sh postgres
