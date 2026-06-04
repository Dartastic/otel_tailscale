# Changelog

## [0.1.0-beta.1] - 2026-06-04

### Added

- Initial release.
- `tracedTailscale<T>(...)` — wraps a otel_tailscale call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutTailscaleInstrumentation()` / `Async()`.
