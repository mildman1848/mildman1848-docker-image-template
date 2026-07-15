#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail=0

# Non-empty check: skip s6 marker files, dependency files, and bundle contents.
while IFS= read -r -d '' file; do
  case "$file" in
    */dependencies.d/*|*/contents.d/*)
      continue
      ;;
  esac
  if [[ ! -s "$file" ]]; then
    echo "ERROR: empty file: $file" >&2
    fail=1
  fi
done < <(find . -type f \
  ! -path './.git/*' \
  ! -path './config/*' \
  -print0)

# Basic s6 sanity checks: only direct service directories below s6-rc.d.
while IFS= read -r -d '' service_dir; do
  name="$(basename "$service_dir")"
  [[ "$name" == "user" ]] && continue
  [[ "$name" == "dependencies.d" ]] && continue
  [[ "$name" == "contents.d" ]] && continue

  if [[ ! -f "$service_dir/type" ]]; then
    echo "ERROR: missing type in $service_dir" >&2
    fail=1
    continue
  fi

  type_value="$(cat "$service_dir/type" 2>/dev/null || true)"
  case "$type_value" in
    oneshot)
      [[ -f "$service_dir/up" || -f "$service_dir/run" ]] || {
        echo "ERROR: oneshot without up/run: $service_dir" >&2
        fail=1
      }
      ;;
    longrun)
      [[ -x "$service_dir/run" ]] || {
        echo "ERROR: longrun without executable run: $service_dir" >&2
        fail=1
      }
      ;;
    bundle)
      ;;
    *)
      echo "ERROR: unknown s6 type '$type_value' in $service_dir" >&2
      fail=1
      ;;
  esac
done < <(find examples -path '*/root/etc/s6-overlay/s6-rc.d/*' -mindepth 1 -maxdepth 7 -type d | awk '/s6-rc.d\/[^/]+$/ {print}' | tr '\n' '\0')

if command -v hadolint >/dev/null 2>&1; then
  find examples -name 'Dockerfile*' -print0 | xargs -0 -r hadolint -c .hadolint.yaml
else
  echo "INFO: hadolint not installed; skipped Dockerfile lint."
fi

exit "$fail"
