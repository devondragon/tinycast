# Fork notes

This is Devon's fork of [abue-ammar/tinycast](https://github.com/abue-ammar/tinycast), licensed
AGPL-3.0 like upstream. `main` here is the fork's own line: upstream changes come in by merge, and
fork changes land through pull requests against `devondragon/tinycast`.

## Remotes

- `origin`: `git@github.com:devondragon/tinycast.git`
- `upstream`: `git@github.com:abue-ammar/tinycast.git`, with its push URL set to `DISABLE`

`gh repo set-default devondragon/tinycast` is set in this clone. Without it, `gh pr create` in a
fork opens the PR against upstream.

## Pulling from upstream

```sh
git fetch upstream --tags
git switch -c sync/upstream-$(date +%F) main
git merge upstream/main
# resolve conflicts, run the tests and a build, then open a PR into main
```

Merge rather than rebase, since `main` is published. Keep fork-only changes small and isolated so
these merges stay easy.

## Fork-only changes

- `Tinycast/Features/Updates/Model/ReleaseFeed.swift`: `repository` points at this fork. The
  in-app updater reads GitHub Releases from that repo, so a fork build never offers an upstream
  release. The fork publishes no releases, so the updater stays idle.
- `Tinycast/Palette/RootPaletteView.swift`: the "releases" link points at this fork.
- Upstream's GitHub Actions (`triage.yml`, `coauthors.yml`, `release.yml`, `website*.yml`) should
  stay disabled on the fork. The triage workflow auto-closes any PR that does not link an
  `approved` issue.

## Building and installing

One-time setup: create the `Tinycast Self-Signed` identity (`docs/signing.md` section 1). Each
machine uses its own key, so macOS asks for Accessibility once after switching from the upstream
build.

```sh
xcodebuild -project Tinycast.xcodeproj -scheme Tinycast -configuration Release \
  -derivedDataPath build/dd build
```

The Release build keeps upstream's bundle id `com.tinycast.app`, so it reuses the existing
settings, clipboard history, notes and snippets. To replace the Homebrew copy:

```sh
brew uninstall --cask tinycast        # no --zap: keeps app data
ditto build/dd/Build/Products/Release/Tinycast.app /Applications/Tinycast.app
```

Debug builds (`Tinycast Dev.app`, `com.tinycast.app.dev`) run side by side with their own data.

## Tests

`./Scripts/run-tests.sh` and `./Scripts/lint.sh`. On macOS 27 a few harnesses fail
intermittently on unmodified upstream code (file-search, icon-cache, clipboard-text,
installed-ai), so compare against a run on `upstream/main` before treating a failure as a
regression.
