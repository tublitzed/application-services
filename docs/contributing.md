# Contributing to Application Services

Anyone is welcome to help with the Application Services project. Feel free to get in touch with other community members on IRC, the
mailing list or through issues here on GitHub.

- IRC: `#sync` on `irc.mozilla.org`
- Mailing list: <https://mail.mozilla.org/listinfo/sync-dev>
- and of course, [the issues list](https://github.com/mozilla/application-services/issues)

Participation in this project is governed by the
[Mozilla Community Participation Guidelines](https://www.mozilla.org/en-US/about/governance/policies/participation/).

## Bug Reports ##

You can file issues here on GitHub. Please try to include as much information as you can and under what conditions
you saw the issue.

## Building the project ##

Build instructions are available [here](building.md). Do not hesitate to let us know which pain-points you had with setting up your environment!

## Sending Pull Requests ##

Patches should be submitted as [pull requests](https://help.github.com/articles/about-pull-requests/) (PRs).

Before submitting a PR:
- Run `cargo fmt` to ensure your Rust code is correctly formatted.
  - If you have modified any Swift code, also run `swiftformat --swiftversion 4` on the modified code.
- Your code must run and pass all the automated tests before you submit your PR for review.
  - The simplest way to confirm this is to use the `./automation/all_tests.sh` script, which runs all test suites
    and linters for Rust, Kotlin and Swift code.
  - "Work in progress" pull requests are welcome, but should be clearly labeled as such and should not be merged until all tests pass and the code has been reviewed.
- Your patch should include new tests that cover your changes, or be accompanied by explanation for why it doesn't need any. It is your
  and your reviewer's responsibility to ensure your patch includes adequate tests.
  - Consult the [testing guide](./howtos/testing-a-rust-component.md) for some tips on writing effective tests.
- Your patch should include a changelog entry in [CHANGES_UNRELEASED.md](../CHANGES_UNRELEASED.md) or an explanation of why
  it does not need one. Any breaking changes to Swift or Kotlin binding APIs should be noted explicitly
- If your patch adds new dependencies, they must follow our [dependency management guidelines](./dependency-management.md).
  Please include a summary of the due dilligence applied in selecting new dependencies.

When submitting a PR:
- You agree to license your code under the project's open source license ([MPL 2.0](/LICENSE)).
- Base your branch off the current `master` (see below for an example workflow).
- Add both your code and new tests if relevant.
- Please do not include merge commits in pull requests; include only commits with the new relevant code.
- Your patch must be [GPG signed](https://help.github.com/articles/managing-commit-signature-verification) to ensure the commits come from a trusted source.

## Code Review ##

This project is production Mozilla code and subject to our [engineering practices and quality standards](https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Committing_Rules_and_Responsibilities). Every patch must be peer reviewed by a member of the Application Services team.
