# setup-linux

Bootstrap script for a Debian/Ubuntu-style Linux box: CLI tools, aliases, and JetBrainsMono Nerd Font.

## Usage

```bash
chmod +x setup-linux.sh
./setup-linux.sh
```

## What it installs

- **eza** (via gierens apt repo) — modern `ls`
- **bat** / **fd-find** — `fd` symlink; `bat` via alias → `batcat`
- **pipx** + **tldr**
- **JetBrainsMono** Nerd Font

Also writes `~/.bash_aliases` (eza/bat/cls aliases) and runs `source ~/.bashrc`.

## After running

Pick **JetBrainsMono Nerd Font** in your terminal settings if the new font doesn’t show up yet.
