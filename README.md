# dotfiles

My terminal setup for Zorin OS (Ubuntu-based): **zsh + Powerlevel10k**, **Alacritty + zellij**, a GitHub Light colour theme everywhere, and the GNOME shortcuts that tie it together.

## Fresh install on Zorin OS

```bash
sudo apt install -y git gh
gh auth login                      # needed to clone this private repo
git clone https://github.com/eliasna1040/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
./install.sh
```

Then:

1. **Log out and back in** so zsh becomes your login shell.
2. Fill in secrets in `~/.zshenv` (created from `zsh/zshenv.example`, never committed).
3. Press **Ctrl+Alt+T** to open Alacritty (inside zellij).
4. Optional: `nvm install --lts` for Node, then install Claude Code with `curl -fsSL https://claude.ai/install.sh | bash`.

`install.sh` is safe to re-run. Any existing file it would replace is moved to `<file>.bak.<timestamp>`.

## What the script does

| Step | Details |
|---|---|
| apt packages | `zsh git curl unzip alacritty ripgrep gh fontconfig dconf-cli` |
| fzf | Latest release binary installed to `/usr/local/bin` (apt's 0.44 is too old for fzf-tab) |
| zellij | Latest release binary installed to `/usr/local/bin` |
| Font | MesloLGS NF (bundled in `fonts/`) copied to `~/.local/share/fonts` |
| Powerlevel10k | Cloned to `~/powerlevel10k` |
| zsh plugins | Cloned to `~/.zsh/plugins/` (see below) |
| Configs | Symlinked from this repo, so editing them in place updates the repo |
| nvm | Installed to `~/.nvm` (`.zshrc` already loads it) |
| GNOME | Ctrl+Alt+T → Alacritty, and a GNOME Terminal profile with zsh and the Meslo font |
| Shell | `chsh` to zsh |

### zsh plugins

| Plugin | What it does |
|---|---|
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Tab completion as a searchable fzf popup |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Grey history suggestions; accept with → or End |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Colours commands as you type (loaded last) |
| [zsh-shift-select](https://github.com/jirutka/zsh-shift-select) | Shift+arrows select text on the command line (Alt+Shift+arrows by word) |

The plugins are plain git clones sourced directly from `.zshrc`, with no oh-my-zsh or plugin manager. Update everything with:

```bash
for d in ~/powerlevel10k ~/.zsh/plugins/*; do git -C "$d" pull --ff-only; done
```

## Repo layout → where it ends up

| Repo file | Linked to |
|---|---|
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/splash/splash.zsh` | `~/.zsh/splash.zsh` (startup banner in new Alacritty windows) |
| `zsh/zshenv.example` | copied once to `~/.zshenv` (secrets, chmod 600) |
| `p10k/p10k.zsh` | `~/.p10k.zsh` (re-run `p10k configure` to change the prompt) |
| `alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
| `zellij/config.kdl`, `zellij/themes/github-light.kdl` | `~/.config/zellij/` |
| `git/gitconfig` | `~/.gitconfig` (uses `gh` as the credential helper) |
| `gnome/*.dconf` | loaded with `dconf load` |
| `fonts/*.ttf` | copied to `~/.local/share/fonts` |

## Keys worth remembering

- **Ctrl+Alt+T**: new Alacritty window (starts zellij)
- **Ctrl+Shift+C / V**: copy and paste in Alacritty (Ctrl+C still interrupts)
- **Ctrl+←/→**, **Ctrl+Backspace/Delete**: move or delete by word (`/ . -` count as word boundaries)
- **Shift+arrows**: select on the command line
- **Tab**: fzf completion popup
- zellij: **Ctrl+g** toggles locked mode; **Ctrl+p** pane mode, **Ctrl+t** tab mode, **Ctrl+n** resize mode

## Saving changes from a running machine

Configs are symlinks, so just commit:

```bash
cd ~/git/dotfiles && git add -A && git commit -m "Update config" && git push
```

GNOME settings are not symlinked, so re-dump them first:

```bash
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > gnome/media-keys.dconf
dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome/gnome-terminal-profiles.dconf
```

## Not included (on purpose)

- `~/.zshenv`: contains tokens. Use the template.
- `~/.ssh`, `~/.gnupg`, shell history, `~/.claude` state.
- .NET SDK and `mssql-tools18`. `.zshrc` adds them to `PATH` if present; install them separately if needed.
