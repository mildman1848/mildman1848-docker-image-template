# Final Pilot Comparison: PostgreSQL and MariaDB vs Master Template Standard

Generated: 2026-07-16T10:14:40+02:00

This document compares the two pilot image repositories against the current master template standard in `mildman1848-docker-image-template`.

## Compared revisions

| Repository | Local path | Revision | Remote sync |
|---|---|---:|---|
| Master template | `/home/captain/workspace/mildman1848-docker-image-template` | `a9c250b` | GitHub, Codeberg, GitLab synced |
| PostgreSQL | `/home/captain/workspace/postgresql` | `ad5c850` | GitHub, Codeberg, GitLab synced |
| MariaDB | `/home/captain/workspace/mariadb` | `a083f1a` | GitHub, Codeberg, GitLab synced |

## Executive summary

| Area | PostgreSQL | MariaDB | Final assessment |
|---|---:|---:|---|
| Template Make surface | ✅ complete | ✅ complete | Both implement the image-repo target surface. |
| Required template files | ✅ complete | ✅ complete | Both carry the shared docs/scripts/community files. |
| Image-specific runtime files | ✅ complete | ✅ complete | Both have Dockerfile, Compose, smoke test, upstream and branding docs. |
| LSIO/s6 runtime model | ✅ | ✅ | No final `USER abc`; app process drops to `abc` via s6/start script. |
| Secret-file support | ✅ | ✅ | `FILE__` flow implemented and tested. |
| Hardened DB smoke test | ✅ | ✅ | Health, valid auth, wrong-password rejection, `abc` process user, no secret leak. |
| Security/SBOM local checks | ✅ | ✅ | Trivy image scan: 0 vulnerabilities; SBOM generated. |
| CI workflows | ✅ | ✅ | Docker, Lint, Security, Mirror all green on current heads. |
| Git mirrors | ✅ | ✅ | GitHub, Codeberg and GitLab heads match. |
| Public branding/privacy | ✅ | ✅ | `Mildman1848` allowed; no forbidden private household term detected. |
| Version suffix policy | ✅ | ✅ | Uses `mldm<N>`; no legacy `mld<N>` suffix detected. |

**Final result:** both pilot repositories are aligned with the current master-template standard. PostgreSQL and MariaDB are suitable as reference implementations for future LSIO-style image repos.

## Make target comparison

The master template defines the reusable target vocabulary. The template itself intentionally has no real `Dockerfile`, so image-only targets such as `smoke` and `labels` are implemented by actual image repositories.

| Target group | Master template | PostgreSQL | MariaDB | Notes |
|---|---:|---:|---:|---|
| Metadata: `help`, `info`, `version` | ✅ | ✅ | ✅ | Present everywhere. |
| Setup/tools: `setup`, `check-tools` | ✅ | ✅ | ✅ | Present everywhere. |
| Env: `env-setup`, `env-validate` | ✅ | ✅ | ✅ | Present everywhere. |
| Validation: `lint`, `validate`, `test` | ✅ | ✅ | ✅ | All `make validate` checks pass. |
| Build: `build`, `build-multiarch`, `build-manifest`, `build-manifest-push` | ✅ | ✅ | ✅ | Local image repos build via `IMAGE_REF`. |
| Manifest: `inspect-manifest`, `validate-manifest` | ✅ | ✅ | ✅ | Present everywhere. |
| Image verification: `smoke`, `labels` | N/A | ✅ | ✅ | Not applicable in template without a real image. |
| Security/SBOM: `scan`, `trivy-scan`, `security-scan`, `sbom` | ✅ | ✅ | ✅ | Alias targets are present by Make database inspection. |
| Container ops: `start`, `stop`, `restart`, `status`, `logs`, `shell` | ✅ | ✅ | ✅ | Present everywhere. |
| Compose: `compose-up`, `compose-down` | ✅ | ✅ | ✅ | Present everywhere. |
| Secrets: `secret`, `secrets`, `secrets-generate`, `secrets-rotate`, `secrets-info`, `secrets-clean` | ✅ | ✅ | ✅ | Image repos add DB-specific secret aliases. |
| Upstream/release: `check-upstream`, `baseimage-check`, `release-dry-run`, `release` | ✅ | ✅ | ✅ | Present everywhere. |
| Cleanup: `clean`, `clean-images` | ✅ | ✅ | ✅ | Present everywhere. |

## File and documentation comparison

| Standard file/category | Master template | PostgreSQL | MariaDB | Notes |
|---|---:|---:|---:|---|
| `.env.example` | ✅ | ✅ | ✅ | Image repos have DB-specific values. |
| `.editorconfig`, `.gitattributes`, `.gitignore`, `.dockerignore` | ✅ | ✅ | ✅ | Present. |
| `.hadolint.yaml` | ✅ | ✅ | ✅ | Present. |
| `SECURITY.md` | ✅ | ✅ | ✅ | Present. |
| Funding/issue/PR templates | ✅ | ✅ | ✅ | Present. |
| `dependabot.yml` | ✅ | ✅ | ✅ | Present. |
| `docs/make-targets.md` | ✅ | ✅ | ✅ | Present. |
| `docs/registries.md` | ✅ | ✅ | ✅ | Present. |
| `docs/security-sbom.md` | ✅ | ✅ | ✅ | Present. |
| `docs/versioning.md` | ✅ | ✅ | ✅ | Present. |
| `docs/secrets.md` | ✅ | ✅ | ✅ | Present. |
| `docs/licensing.md` | ✅ | ✅ | ✅ | Present. |
| `docs/branding.md` | N/A | ✅ | ✅ | Image-specific startup branding docs. |
| `UPSTREAM.md` | N/A | ✅ | ✅ | Image-specific upstream policy. |
| `Dockerfile` | N/A | ✅ | ✅ | Template intentionally has none. |
| `docker-compose.yml` | N/A | ✅ | ✅ | Image-specific local run example. |
| `smoke-test.sh` | N/A | ✅ | ✅ | Image-specific hardened smoke test. |
| `scripts/buildx-build.sh` | ✅ | ✅ | ✅ | Present. |
| `scripts/generate-secret.py` | ✅ | ✅ | ✅ | Present. |
| `scripts/lint-static.sh` | ✅ | ✅ | ✅ | Present. |
| `scripts/setup-tools.sh` | ✅ | ✅ | ✅ | Present. |

## Runtime and security comparison

| Requirement | PostgreSQL | MariaDB | Evidence |
|---|---:|---:|---|
| LSIO baseimage pattern | ✅ | ✅ | Built images report Alpine 3.24.1 and LSIO-style runtime. |
| No final Dockerfile `USER abc` | ✅ | ✅ | Required for LSIO `/init` and s6 initialization. |
| Final DB process runs as `abc` | ✅ | ✅ | Verified by hardened smoke tests. |
| `FILE__` secret support | ✅ | ✅ | Smoke tests mount generated secret files. |
| Authenticated health/readiness | ✅ | ✅ | PostgreSQL uses `psql`; MariaDB uses authenticated client checks. |
| Wrong password rejected | ✅ | ✅ | Explicitly tested. |
| Secret value absent from logs | ✅ | ✅ | Explicitly tested. |
| Trivy image vulnerabilities | ✅ 0 | ✅ 0 | Local `make security-scan` completed. |
| Trivy `DS-0002` | documented exception | documented exception | Expected for LSIO/s6 images because final `USER` must not be set. |
| SBOM generated | ✅ `868391` bytes | ✅ `2028226` bytes | SPDX JSON generated under `sbom/`. |

## CI and mirror comparison

| Workflow / integration | Master template | PostgreSQL | MariaDB | Notes |
|---|---:|---:|---:|---|
| Lint workflow | ✅ | ✅ | ✅ | Latest pilot runs green. |
| Docker workflow | ✅ template reusable/build workflow | ✅ | ✅ | Pilot image builds green in GitHub Actions. |
| Security workflow | ✅ | ✅ | ✅ | Latest pilot runs green. |
| Mirror workflow | ✅ | ✅ | ✅ | GitHub → Codeberg/GitLab. |
| Upstream monitor | N/A | ✅ | ✅ | Image-specific. |
| Docker Actions versions | ✅ v4/v7/v6 standard | ✅ v4/v7/v6 standard | ✅ v4/v7/v6 standard | `checkout@v7`, Buildx/QEMU/Login v4, build-push v7, metadata v6. |
| GitHub head synced to Codeberg | ✅ | ✅ | ✅ | Verified by remote HEAD comparison. |
| GitHub head synced to GitLab | ✅ | ✅ | ✅ | Verified by remote HEAD comparison. |

Latest pilot workflow status:

| Repo | Docker | Lint | Security | Mirror |
|---|---:|---:|---:|---:|
| PostgreSQL `ad5c850` | ✅ success | ✅ success | ✅ success | ✅ success |
| MariaDB `a083f1a` | ✅ success | ✅ success | ✅ success | ✅ success |

## Versioning and public artifact policy

| Requirement | PostgreSQL | MariaDB | Result |
|---|---:|---:|---|
| Combined version format `<upstream>-mldm<N>` | `16.14-mldm1` | `11.8.8-mldm2` | ✅ |
| Legacy `mld<N>` suffix absent | ✅ | ✅ | ✅ |
| Public brand `Mildman1848` allowed | ✅ | ✅ | ✅ |
| Forbidden private household term absent | ✅ | ✅ | ✅ |
| Image labels expose version | ✅ | ✅ | ✅ |

## Local verification commands run

```bash
# all three repos
make validate

# PostgreSQL
make test DOCKER='sudo docker'
make security-scan DOCKER='sudo docker' TRIVY='sudo trivy'
make sbom DOCKER='sudo docker' SYFT='sudo syft'

# MariaDB
make test DOCKER='sudo docker'
make security-scan DOCKER='sudo docker' TRIVY='sudo trivy'
make sbom DOCKER='sudo docker' SYFT='sudo syft'
```

Observed image metadata:

| Image | Version | Image ID | Size |
|---|---:|---|---:|
| `ghcr.io/mildman1848/postgresql:16.14-mldm1` | `16.14-mldm1` | `sha256:4a8332115350...` | `59782020` bytes |
| `ghcr.io/mildman1848/mariadb:11.8.8-mldm2` | `11.8.8-mldm2` | `sha256:62594ebc0bee...` | `317557219` bytes |

## Final recommendation

Use **PostgreSQL** and **MariaDB** as the two reference implementations for the current master-template standard:

1. PostgreSQL is the better reference for SCRAM/TCP auth hardening and `pg_hba.conf` pitfalls.
2. MariaDB is the better reference for heavier DB initialization, authenticated healthchecks, and larger runtime image behavior.
3. The template should not receive more features until the same standard is applied to at least one small non-database image. Otherwise the template will grow into a shrine to hypothetical elegance. Those rarely pass `make test`.

## Remaining optional follow-ups

| Priority | Follow-up | Reason |
|---:|---|---|
| 1 | Apply this standard to one tiny non-DB image | Confirms the template is pleasant outside databases. |
| 2 | Test multiarch build paths beyond `linux/amd64` | Required before claiming Raspberry Pi support. |
| 3 | Enable registry publishing only after secret/path verification | Git mirrors are green; container registries are separate public artifacts. |
| 4 | Consider documenting the two pilot repos as canonical examples in `README.md` | Makes the template easier to reuse later. |
