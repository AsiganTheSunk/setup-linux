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
alias ll="eza -l --icons --hyperlink --git --git-repos"
alias la="eza -la --icons --hyperlink --git --git-repos"
alias lt="eza --tree --icons --hyperlink --git --git-repos"
alias ltt="eza -la --tree --level=2 --icons --hyperlink --git --git-repos"
alias lttt="eza -la --tree --level=3 --icons --hyperlink --git --git-repos"
alias ltttt="eza -la --tree --level=4 --icons --hyperlink --git --git-repos"
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

