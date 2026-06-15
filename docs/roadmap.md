# Roadmap

This file tracks ideas that are useful enough to keep, but not required for the
current role release.

## Testing

- Add Molecule scenarios for Docker-backed services, undeploy, grouped services,
  and macOS rendering.
- For Docker-backed service coverage, prefer Docker-in-Docker inside the
  privileged Molecule systemd instance over host socket passthrough. The role
  renders unit/env files inside the instance, and host socket passthrough would
  make the host Docker daemon resolve container env-file paths on the host.
- The Docker-backed scenario should install Docker plus the Python Docker
  bindings, deploy a small long-running image such as `busybox sleep 3600`, and
  verify both the service state and `docker inspect` running state.
- Add a lightweight render-only scenario for Darwin facts if a native macOS
  runner is not available.

## Role Behavior

- Validate required runtime dependencies before deployment, such as Docker for
  container services and `launchctl` or systemd availability for the target OS.
- Expand service dictionaries so command services and container services can use
  one consistent structured input shape.
- Consider async restarts for grouped services where services can be restarted
  independently.

## Cleanup

- Remove legacy compatibility paths once the role input model is stable.
