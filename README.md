# OPA ScaleFT Containers

> [!CAUTION]
> **Not an Official Okta Product** - This is an independent community project and is not an official Okta product. Use at your own risk and always test in a non-production environment first.

Small Debian-based container images with Okta Privileged Access ScaleFT packages preinstalled.

This repository publishes reusable images for automation and lab use. OPA Workloads is one useful example for the client image, but the images are generic and can support other CI/CD, scripting, and operational workflows.

No OPA credentials, API keys, enrollment tokens, team configuration, or workload tokens are baked into these images.

## Images

| Image | Dockerfile | Package | Use case |
|-------|------------|---------|----------|
| `ghcr.io/fabiograsso/opa-scaleft-client` | `Dockerfile.client` | `scaleft-client-tools` | CI/CD automation, Workloads, `sft` CLI operations, SSH smoke tests |
| `ghcr.io/fabiograsso/opa-scaleft-gateway` | `Dockerfile.gateway` | `scaleft-gateway` | Lab or automation base image for OPA gateway package experiments |

Each image is published with:

```text
latest
<package-version>
```

Example tags:

```text
ghcr.io/fabiograsso/opa-scaleft-client:latest
ghcr.io/fabiograsso/opa-scaleft-client:1.108.0
ghcr.io/fabiograsso/opa-scaleft-gateway:latest
ghcr.io/fabiograsso/opa-scaleft-gateway:1.108.0
```

## What Is Included

Both images use `debian:12-slim` and the stable Okta PAM apt repository for Debian 12 `bookworm`.

The client image includes:

- Okta Privileged Access `scaleft-client-tools`
- `bash`
- `curl`
- `jq`
- OpenSSH client
- `script` from `util-linux`, useful when a non-interactive runner needs a pseudo-terminal

The gateway image includes:

- Okta Privileged Access `scaleft-gateway`
- `bash`
- `curl`
- `jq`
- `script` from `util-linux`

The gateway image is intentionally unconfigured. It does not include enrollment tokens, labels, tenant settings, or runtime secrets.

## Publishing To GHCR

The repository includes one GitHub Actions workflow:

```text
.github/workflows/publish.yml
```

It runs on:

- manual dispatch
- push to `main` when `Dockerfile.client`, `Dockerfile.gateway`, or the publish workflow changes
- a weekly schedule, every Monday at 06:00 UTC

The workflow uses the built-in `GITHUB_TOKEN`, so no personal access token is required for publishing from this repository.

Required workflow permissions:

```yaml
permissions:
  contents: read
  packages: write
```

For each image, scheduled runs read the Debian `Packages` metadata from the Okta PAM apt repository before building. The workflow extracts all versions for the target package, selects the latest with version-aware sorting, and checks GHCR for the matching tag. If the tag already exists, that image is skipped. If the tag is new, the workflow builds the image, runs a smoke test, and publishes both `latest` and the version tag.

The first push creates GitHub Container Registry packages. GHCR packages are private by default when first published. You can later change visibility or grant repository access from the package settings.

## Using The Client Image In GitHub Actions

For workflows in a repository that can read the package:

```yaml
jobs:
  automation:
    runs-on: ubuntu-24.04
    container:
      image: ghcr.io/fabiograsso/opa-scaleft-client:latest

    permissions:
      contents: read
      packages: read

    steps:
      - name: Check sft
        run: sft --version
```

If the package is private and used from another repository, grant that repository access in:

```text
Package settings -> Manage Actions access
```

## Example: OPA Workloads

The client image can be used by a GitHub Actions workflow that obtains a GitHub OIDC token, exchanges it with OPA Workloads using `sft wl authenticate`, and then performs automation such as:

```bash
sft secrets reveal --path production_server_secrets --name MySql_root
```

or:

```bash
script -q -e -c "sft ssh 'opa-linux-target' --command 'hostname && uname -a && whoami'" /dev/null
```

Keep workload tokens short-lived and avoid printing raw tokens in production logs.

For a complete GitHub Actions lab that demonstrates OPA Workloads with secret reveal and SSH smoke tests, see:

```text
https://github.com/fabiograsso/okta-lab-workloads
```

## Local Build

```bash
docker build -f Dockerfile.client -t opa-scaleft-client:local .
docker run --rm opa-scaleft-client:local sft --version

docker build -f Dockerfile.gateway -t opa-scaleft-gateway:local .
docker run --rm opa-scaleft-gateway:local dpkg -l scaleft-gateway
```

## References

- [Okta Privileged Access clients](https://help.okta.com/oie/en-us/content/topics/privileged-access/clients/pam-clients.htm)
- [Install the Okta Privileged Access client on Ubuntu or Debian](https://help.okta.com/oie/en-us/content/topics/privileged-access/tool-setup/pam-sft-ubuntu.htm)
- [Install the Okta Privileged Access gateway on Ubuntu or Debian](https://help.okta.com/en-us/content/topics/privileged-access/tool-setup/pam-gateway-install-ubuntu.htm)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
