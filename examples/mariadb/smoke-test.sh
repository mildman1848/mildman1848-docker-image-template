#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: smoke-test.sh IMAGE}"
name="mariadb-lsio-smoke-$$"
tmpdir="$(mktemp -d)"
trap 'docker rm -f "$name" >/dev/null 2>&1 || true; rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/config"
printf 'app-change-me
' > "$tmpdir/mysql_password"
printf 'root-change-me
' > "$tmpdir/mysql_root_password"

docker run -d --name "$name"   -e PUID="$(id -u)"   -e PGID="$(id -g)"   -e MYSQL_DATABASE=smoke   -e MYSQL_USER=smoke   -e FILE__MYSQL_PASSWORD=/run/secrets/mysql_password   -e FILE__MYSQL_ROOT_PASSWORD=/run/secrets/mysql_root_password   -v "$tmpdir/config:/config"   -v "$tmpdir/mysql_password:/run/secrets/mysql_password:ro"   -v "$tmpdir/mysql_root_password:/run/secrets/mysql_root_password:ro"   "$image"

for _ in {1..60}; do
  if docker exec "$name" /usr/local/bin/healthcheck >/dev/null 2>&1; then
    echo "MariaDB smoke test passed"
    exit 0
  fi
  sleep 2
done

docker logs "$name"
exit 1
