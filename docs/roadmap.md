# Roadmap

This file tracks ideas that are useful enough to keep, but not required for the
current role release.

## Testing

- Add Molecule scenarios for Docker-backed services, undeploy, grouped services,
  and macOS rendering.
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
