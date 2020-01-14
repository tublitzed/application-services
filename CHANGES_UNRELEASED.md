**See [the release process docs](docs/howtos/cut-a-new-release.md) for the steps to take when cutting a new release.**

# Unreleased Changes

[Full Changelog](https://github.com/mozilla/application-services/compare/v0.48.2...master)

## Places

### What's new

* Places now exposes `resetHistorySyncMetadata` and `resetBookmarkSyncMetadata`
  methods, which cleans up all Sync state, including tracking flags and change
  counters. These methods should be called by consumers when the user signs out,
  to avoid tracking changes and causing unexpected behavior the next time they
  sign in (PR #2447).
