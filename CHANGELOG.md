## [Unreleased]

### Added

- `Kubik::Setting.cached_settings_hash` / `build_settings_hash` for public layout assigns (defaults merged, `kubik/settings` cache key).
- `KubikSettings::FrontendViewContext` concern for `@kubik_settings`, navigation helper assigns, and preview instance-variable hooks.

### Changed

- `Kubik::Setting#flush_cache` also clears `kubik/settings` (matches frontend cache reads).

### Ruby gem

- Bump patch from **0.5.2** after release; host apps remove any local `kubik_setting_frontend_cache` initializer.

## [0.5.2] - 2026-11-04

### Added

- `KubikSettings::Discoverability` suggested settings keys and default `settings_hash` fragment for crawler policy, robots.txt, llms.txt, and schema.org blocks.

### Changed

- Active Admin settings resource passes arbitrary `menu_options` to `menu` and flushes `Kubik::Discoverability` caches after save when loaded.

## [0.5.1] - 2026-10-01

- Setting updates and split resource definitions.
