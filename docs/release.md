# Release

How a build reaches a user. The local development loop is in [development.md](development.md);
the signing identity itself is in [signing.md](signing.md).

## Packaging a DMG locally

```sh
./Scripts/build-dmg.sh            # -> build/Tinycast-<version>.dmg (version from project.yml)
./Scripts/build-dmg.sh 0.5.7      # -> build/Tinycast-0.5.7.dmg
```

It builds a Release `Tinycast.app` signed with `Tinycast Self-Signed` and packs it with an
`/Applications` symlink. Official per-channel releases are built by CI, below.

## Signing & Gatekeeper

CI releases are signed with the team's Developer ID, notarized and stapled, so a downloaded DMG
opens without a Gatekeeper warning. Local builds, `build-dmg.sh` included, keep signing with
`Tinycast Self-Signed` and are never notarized. Full details in [signing.md](signing.md).

## How the in-app updater consumes a release

Every release publishes three assets from one build: `Tinycast-<version>.dmg`, which people download
by hand and which the cask installs, `Tinycast-<version>.zip`, which the in-app updater installs, and
`Tinycast-<version>.zip.sig`, the zip's signature by the release key. The zip is produced with
`ditto -c -k --keepParent --sequesterRsrc` — the only zip that leaves the code signature verifiable,
which matters because the updater refuses any bundle it cannot prove is ours.

A stable release publishes two more from the `universal` job, `Tinycast-Universal-<version>.dmg` and
`.zip`, built from the same commit at the same version and bundle id but with both slices. They are
uploaded _after_ the thin pair, which keeps the thin zip first in the asset list so builds predating
architecture-aware selection keep choosing it.

Three things a release must keep true, or the updater skips it:

- **It carries a `.zip` asset this Mac can run.** A DMG-only release is not installable and is not
  offered, and an Intel build is offered nothing rather than a thin arm64 zip.
- **The tag parses as `vMAJOR.MINOR.PATCH` or `vMAJOR.MINOR.PATCH-beta.N`,** and agrees with the
  `prerelease` flag. A tag of any other shape is treated as mis-published and skipped.
- **It is not a draft.**

**Every cask declares `auto_updates true`.** That is Homebrew's flag for an app that manages its own
version, and it is what keeps `brew update && brew upgrade` from fighting an app that updated itself:
brew never reports Tinycast outdated, never re-downloads it, and never rolls a self-updated copy back.
Removing that line would reintroduce exactly those three problems. See
[features/updates.md](features/updates.md).

## Pull request review

There is no CI workflow and no automated reviewer on this fork, so the whole bar in
[testing.md](testing.md#definition-of-done) is run locally before a PR is opened.

## Releasing

**This fork publishes no releases.** The in-app updater reads GitHub Releases from
`devondragon/tinycast` (`ReleaseFeed.repository`), which has none, and automatic checking defaults
off, so the only way a build reaches this Mac is `./Scripts/install-fork.sh`, described in
[FORK.md](../FORK.md). It builds a signed Release from the checkout, stamps it with the newest
upstream stable tag and the fork's commit count, verifies the signature, and swaps it into
`/Applications`.

`.github/workflows/release.yml`, `Scripts/release-notes.sh` and the Homebrew tap steps are upstream's
pipeline, kept only so upstream merges stay clean. They need upstream's signing secret, tap token and
Discord webhook, and GitHub Actions is turned off for the fork, so none of them runs here. Upstream's
own description of that pipeline lives in its copy of this file.

Should the fork ever publish, three things the updater requires (above) still hold, plus one more:
without upstream's release key and a Developer ID signature, a downloaded bundle is trusted only
when it satisfies the running copy's designated requirement, so every fork release would have to be
signed with one shared `Tinycast Self-Signed` key rather than a per-machine one.
