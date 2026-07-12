# homebrew-tap

Homebrew tap for projects by [@alyraffauf](https://github.com/alyraffauf).

## Usage

```
brew tap alyraffauf/tap
```

## Formulae

| Formula | Description |
|---------|-------------|
| `atbbs` | AT Protocol bulletin board system |
| `dewy`  | Minimal terminal UI for Todoist |
| `tg`    | Command-line client for Tangled, the git forge built on atproto |

```
brew install atbbs
brew install dewy
brew install tg
```

## Casks

Linux-only, x86_64 casks.

| Cask | Description |
|------|-------------|
| `zed-linux` | Zed code editor (stable) |
| `visual-studio-code-linux` | Visual Studio Code |
| `opencode-desktop-linux` | OpenCode AI coding agent desktop client |
| `emacs-app-linux` | Emacs with PGTK (native Wayland/X11) |
| `obsidian-linux` | Knowledge base on top of local Markdown files |
| `helium-linux` | Private, fast, and honest web browser |

```
brew install --cask zed-linux
```

## Automation

- **`atbbs`** and **`dewy`** are updated by their own release-triggered workflows.
- Everything else (**`tg`** and all casks) is bumped daily by `brew bump` (`.github/workflows/bump.yml`), which opens a PR per outdated package and enables auto-merge.
- Bump PRs are gated by CI (`.github/workflows/ci.yml`): `brew style` + `brew audit`, formula install/test on macOS and Linux, and `brew fetch --cask` to verify cask checksums. The `ci-complete` job is the required status check.

Auto-merge requires **Settings → General → Allow auto-merge** enabled, and a branch protection rule on `main` requiring the **`ci-complete`** check.
