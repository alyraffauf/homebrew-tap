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
| `dewy` | Minimal terminal UI for Todoist |
| `obsidian-headless` | Headless client for Obsidian Sync and Publish |
| `tg` | Command-line client for Tangled, the git forge built on atproto |

```
brew install atbbs
brew install dewy
brew install obsidian-headless
brew install tg
```

## Casks

Linux-only, x86_64 casks.

| Cask | Description |
|------|-------------|
| `emacs-app-linux` | Emacs with PGTK (native Wayland/X11) |
| `helium-linux` | Private, fast, and honest web browser |
| `obsidian-linux` | Knowledge base on top of local Markdown files |
| `opencode-desktop-linux` | OpenCode AI coding agent desktop client |
| `todoist-linux` | To-do list and task manager |
| `visual-studio-code-linux` | Visual Studio Code |
| `zed-linux` | Zed code editor (stable) |

```
brew install --cask zed-linux
```

## Automation

- **`atbbs`** and **`dewy`** are updated by their own release-triggered workflows.
- **`tg`** and all casks are bumped daily by `brew bump` (`.github/workflows/bump.yml`), which opens a PR per outdated package and enables auto-merge.
- CI (`.github/workflows/ci.yml`) runs `brew style` + `brew audit`, formula install/test on macOS and Linux, and `brew fetch --cask` to verify cask checksums. The `ci-complete` job is the required status check.

Auto-merge requires **Settings → General → Allow auto-merge** enabled, and a branch protection rule on `main` requiring the **`ci-complete`** check.
