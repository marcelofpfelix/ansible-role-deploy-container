# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-05-17

### Added

- Added Linux/systemd and macOS/launchd service deployment support.
- Added command-service and Docker-backed service runtimes.
- Added automatic OS-specific service rendering and service control.
- Added grouped deploy and undeploy task support.
- Added pre-commit, ansible-lint, Molecule, Makefile, Dockerfile, and GitHub Actions tooling.

### Changed

- Reworked service templates for systemd units and launchd plist/wrapper files.
- Updated test workflow to use Molecule scenario coverage instead of legacy manual test playbooks.

### Fixed

- Use `launchctl` for macOS service load/unload instead of systemd commands.

[unreleased]: https://github.com/marcelofpfelix/ansible-role-deploy-container/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/marcelofpfelix/ansible-role-deploy-container/releases/tag/v0.1.0
