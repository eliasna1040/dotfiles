#!/usr/bin/env bash
# Sets up zsh + Powerlevel10k + plugins, Alacritty + zellij and the GNOME bits on a fresh Zorin OS / Ubuntu.
# Safe to re-run: existing files are moved to *.bak.<timestamp> before being replaced by symlinks.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"

say() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# Symlink $1 (in repo) to $2, backing up anything already there
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then return; fi
  if [[ -e "$dst" || -L "$dst" ]]; then mv "$dst" "$dst.bak.$STAMP"; fi
  ln -s "$src" "$dst"
  echo "  $dst -> $src"
}

# Clone or update a git repo
clone() {
  local url="$1" dir="$2"
  if [[ -d "$dir/.git" ]]; then git -C "$dir" pull --ff-only -q; else git clone --depth=1 -q "$url" "$dir"; fi
  echo "  $dir"
}

say "Installing apt packages"
sudo apt-get update -q
sudo apt-get install -y zsh git curl unzip alacritty ripgrep gh fontconfig dconf-cli

say "Installing fzf (latest release; apt's is too old for fzf-tab's popup)"
FZF_VER="$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest | grep -oP '"tag_name": "v\K[^"]+')"
curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${FZF_VER}/fzf-${FZF_VER}-linux_amd64.tar.gz" \
  | sudo tar -xz -C /usr/local/bin fzf
fzf --version

say "Installing zellij (latest release)"
curl -fsSL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz \
  | sudo tar -xz -C /usr/local/bin zellij
zellij --version

say "Installing MesloLGS NF font"
mkdir -p ~/.local/share/fonts
cp "$DOTFILES"/fonts/*.ttf ~/.local/share/fonts/
fc-cache -f >/dev/null

say "Installing Powerlevel10k and zsh plugins"
clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/plugins/zsh-autosuggestions
clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting
clone https://github.com/Aloxaf/fzf-tab.git ~/.zsh/plugins/fzf-tab
clone https://github.com/jirutka/zsh-shift-select.git ~/.zsh/plugins/zsh-shift-select

say "Linking config files"
link "$DOTFILES/zsh/zshrc"                        ~/.zshrc
link "$DOTFILES/zsh/splash/splash.zsh"            ~/.zsh/splash.zsh
link "$DOTFILES/p10k/p10k.zsh"                    ~/.p10k.zsh
link "$DOTFILES/alacritty/alacritty.toml"         ~/.config/alacritty/alacritty.toml
link "$DOTFILES/alacritty/themes"                 ~/.config/alacritty/themes
link "$DOTFILES/zellij/config.kdl"                ~/.config/zellij/config.kdl
link "$DOTFILES/zellij/themes/zorin-dark.kdl"     ~/.config/zellij/themes/zorin-dark.kdl
link "$DOTFILES/zellij/themes/zorin-light.kdl"    ~/.config/zellij/themes/zorin-light.kdl
link "$DOTFILES/git/gitconfig"                    ~/.gitconfig

say "Selecting colour theme (Zorin Dark unless 'light' was chosen before; switch later with: theme dark|light)"
THEME="$(cat ~/.config/dotfiles/theme 2>/dev/null || true)"
[[ "$THEME" == light ]] || THEME=dark
mkdir -p ~/.config/dotfiles
echo "$THEME" > ~/.config/dotfiles/theme
ln -sfn ~/.config/alacritty/themes/zorin-$THEME.toml ~/.config/alacritty/theme.toml
echo "  $THEME"

if [[ ! -f ~/.zshenv ]]; then
  cp "$DOTFILES/zsh/zshenv.example" ~/.zshenv
  chmod 600 ~/.zshenv
  echo "  created ~/.zshenv from template (fill in your secrets)"
fi

say "Installing nvm"
if [[ ! -d ~/.nvm ]]; then
  NVM_VER="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oP '"tag_name": "\K[^"]+')"
  PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VER}/install.sh)"
fi

say "Loading GNOME settings (Ctrl+Alt+T -> Alacritty, GNOME Terminal profile font)"
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$DOTFILES/gnome/media-keys.dconf"
# The terminal profile is keyed by a UUID, so make it the default profile too
dconf load /org/gnome/terminal/legacy/profiles:/ < "$DOTFILES/gnome/gnome-terminal-profiles.dconf"
PROFILE_ID="$(grep -oP '^\[:\K[^\]]+' "$DOTFILES/gnome/gnome-terminal-profiles.dconf" | head -1)"
if [[ -n "$PROFILE_ID" ]]; then
  dconf write /org/gnome/terminal/legacy/profiles:/list "['$PROFILE_ID']"
  dconf write /org/gnome/terminal/legacy/profiles:/default "'$PROFILE_ID'"
fi

say "Setting zsh as login shell"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

say "Done. Log out and back in (for the login shell), then press Ctrl+Alt+T."
