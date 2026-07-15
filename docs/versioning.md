# Versioning Policy

Image versions follow a LinuxServer.io-inspired pattern while making the upstream version explicit.

## Format

```text
<upstream-version>-mld<N>
```

Examples:

```text
16.14-mld1
11.8.8-mld1
```

## Meaning

| Part | Meaning |
|---|---|
| `<upstream-version>` | Version of the packaged upstream application or package. |
| `mld<N>` | Our image packaging revision for that upstream version. |

## When to bump

- Upstream package/application changes: bump `<upstream-version>` and reset `mld1`.
- Packaging-only changes with the same upstream version: bump `mld<N>`.
- Security/baseimage-only rebuild with no functional packaging change: bump `mld<N>` if republished.

## Labels

Images should include:

- `org.opencontainers.image.version=<upstream-version>-mld<N>`
- `APP_VERSION=<upstream-version>`
- `IMAGE_REVISION=mld<N>`
- LSIO-style `build_version` with upstream and image revision details.
