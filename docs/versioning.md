# Versioning Policy

Image versions follow a LinuxServer.io-inspired pattern while making the upstream version explicit.

## Format

```text
<upstream-version>-milde<N>
```

Examples:

```text
16.14-milde1
11.8.8-milde1
```

## Meaning

| Part | Meaning |
|---|---|
| `<upstream-version>` | Version of the packaged upstream application or package. |
| `milde<N>` | Our image packaging revision for that upstream version. |

## When to bump

- Upstream package/application changes: bump `<upstream-version>` and reset `milde1`.
- Packaging-only changes with the same upstream version: bump `milde<N>`.
- Security/baseimage-only rebuild with no functional packaging change: bump `milde<N>` if republished.

## Labels

Images should include:

- `org.opencontainers.image.version=<upstream-version>-milde<N>`
- `APP_VERSION=<upstream-version>`
- `IMAGE_REVISION=milde<N>`
- LSIO-style `build_version` with upstream and image revision details.
