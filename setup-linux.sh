#!/usr/bin/env bash

# Abort on error, unset variables, or failed pipelines
set -euo pipefail

# Add eza apt repository
sudo mkdir -p /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/gierens.gpg ]]; then
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
fi
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Seutp base packages
sudo apt update
sudo apt install -y eza gpg wget curl unzip git fontconfig pipx bat fd-find

# Setup pipx apps
sudo pipx ensurepath --global
pipx install tldr

# Setup bash_aliases
cat > ~/.bash_aliases <<'EOF'
# CLEAR Alias
alias cls="clear"

# FDFind Alias
alias fd="fdfind"

# BAT Alias
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
EOF

# Setup NerdFont (JetBrainsMono)
mkdir -p ~/.local/share/fonts
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
wget -qO "$tmp/JetBrainsMono.zip" \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -qo "$tmp/JetBrainsMono.zip" -d ~/.local/share/fonts/JetBrainsMono
fc-cache -fv

echo "[~]: Done ( source ~/.bashrc or restart the shell )"
