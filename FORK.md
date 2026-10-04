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
- The in-app donation prompt is off: `AppCore` no longer starts the Support reminder, and the
  menu bar, palette menu, launcher command (`CommandID.support`) and the Settings → About card are
  gone. About links to this fork and to upstream, and its footer credits the fork. The
  `Features/Support/` code and its settings key remain, unused, to keep merges small.
- `Scripts/install-fork.sh`: build and install, described below.
- `README.md`: fork notice and build-from-source install; upstream's private email, tip/support
  links, Discord, star history and Contributing section are removed. Expect conflicts here when
  merging upstream; keep the fork's version of those parts.
- Upstream's contribution process is removed: `CONTRIBUTING.md`, the contributor agreement,
  `.github/FUNDING.yml`, `.coderabbit.yaml`, `docs/support-button.svg`, and the `triage.yml` and
  `coauthors.yml` workflows are deleted; the PR template, issue templates and `docs/release.md`'s
  review section are simplified. A merge that touches a deleted file shows a modify/delete
  conflict; keep it deleted.
- GitHub Actions is turned off for the whole fork (repo setting, not a file change). The remaining
  `release.yml` and `website*.yml` workflows are upstream's release and website deploys, which need
  his signing secrets and hosting; they are kept only so upstream merges stay clean. Rework or delete
  them before turning Actions on.

## Building and installing

One-time setup: create the `Tinycast Self-Signed` identity (`docs/signing.md` section 1). Each
machine uses its own key, so macOS asks for Accessibility once after switching from the upstream
build.

`./Scripts/install-fork.sh` builds a signed Release from the current checkout, stamps it with the
newest upstream tag's version and a commit-count build number, quits the running copy, replaces
`/Applications/Tinycast.app` and relaunches it. The bundle id stays `com.tinycast.app`, so settings,
clipboard history, notes and snippets carry over. The Homebrew cask was uninstalled on 2026-10-03
(without `--zap`); do not reinstall it, since its copy would replace this one.

Debug builds (`Tinycast Dev.app`, `com.tinycast.app.dev`) run side by side with their own data.

## Tests

`./Scripts/run-tests.sh` and `./Scripts/lint.sh`. On macOS 27 a few harnesses fail
intermittently on unmodified upstream code (file-search, icon-cache, clipboard-text,
installed-ai), so compare against a run on `upstream/main` before treating a failure as a
regression.
