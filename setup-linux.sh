#!/usr/bin/env bash

set -euo pipefail

# 1. eza apt repository
sudo mkdir -p /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/gierens.gpg ]]; then
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
fi
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# 2. Base packages (needed for repos, fonts, and tools)
sudo apt update
sudo apt install -y eza gpg wget curl unzip git fontconfig pipx bat fd-find

# 3. User bin + Debian name workarounds (batcat -> bat, fdfind -> fd)
mkdir -p ~/.local/bin
#[[ -e ~/.local/bin/bat ]] || ln -s /usr/bin/batcat ~/.local/bin/bat
[[ -e ~/.local/bin/fd ]] || ln -s "$(command -v fdfind)" ~/.local/bin/fd

# 4. pipx apps (after PATH helpers exist)
sudo pipx ensurepath --global
pipx install tldr

# 5. Shell config: PATH + bash_aliases
cat > ~/.bash_aliases <<'EOF'
# BAT Aliases
alias bat="batcat"

# EZA Aliases
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias lt="eza --tree"
alias lt2="eza --tree --level=2"
alias lta="eza --tree -a"
alias lta2="eza --tree --level=2 -a"
alias ltha="eza -lh --tree -a --level=1"
# alias lg="eza -l --git"
# alias lft="eza --tree | fd"

# CLEAR Aliases
alias cls="clear"
EOF

source ~/.bashrc

# 6. Nerd Font (JetBrainsMono) — download release zip, not full git clone
mkdir -p ~/.local/share/fonts
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
wget -qO "$tmp/JetBrainsMono.zip" \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -qo "$tmp/JetBrainsMono.zip" -d ~/.local/share/fonts/JetBrainsMono
fc-cache -fv

echo "Done. Restart the shell (or: source ~/.bashrc)"
