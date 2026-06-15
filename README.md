# ansible-role-deploy-service

Deploy services on Linux/systemd and macOS/launchd.

Current version: `0.1.0`

The role supports two runtimes:

- `command`: a normal service started from `service_exec_start`
- `container`: a Docker-backed service, compatible with the old `container` variable

## Generic service

```yaml
- hosts: all
  roles:
    - role: ansible-role-deploy-service
      vars:
        service_name: my-worker
        service_exec_start: /usr/local/bin/my-worker --config /etc/my-worker.yml
        service_restart: on-failure
```

## Docker container service

```yaml
- hosts: all
  roles:
    - role: ansible-role-deploy-service
      vars:
        container: whoami
        registryns: traefik
```

On macOS, the role renders a launchd plist under `~/Library/LaunchAgents` and
uses `launchctl` to load and unload the service. On Linux, it renders a systemd
unit under `/etc/systemd/system`.

## Testing

```console
make pre
make molecule
make check
```

`make molecule` runs the current Molecule scenario. Today that scenario verifies
the command-service path by rendering and starting a systemd unit inside a
privileged Docker test instance.

Docker-backed services need their own end-to-end scenario. The preferred shape is
to run Docker inside the Molecule systemd instance, install the Docker Python
bindings and `community.docker`, apply this role with `deploy_service_runtime:
container`, then verify both the rendered systemd unit and the container state
with `docker inspect`. Avoid mounting the host Docker socket for this test: the
generated unit refers to files inside the Molecule instance, such as
`/etc/docker/<service>.env`, and a host daemon would resolve those paths on the
host instead.

## Test coverage

This role does not publish line coverage. The tested surface is tracked through
Molecule scenarios instead: each scenario should cover one role path, such as a
command service, a Docker-backed service, undeploy, or grouped services.
