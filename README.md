# setup-linux

Bootstrap scripts for a Debian/Ubuntu-style Linux box: CLI tools, aliases, fonts, and optional static IP.

## Scripts

### `setup-packages.sh`

Installs CLI tools, writes `~/.bash_aliases`, and installs JetBrainsMono Nerd Font.

```bash
chmod +x setup-packages.sh
./setup-packages.sh
```

**Installs**

- **eza** (gierens apt repo) — modern `ls`
- **bat** / **fd-find** — aliases `bat` → `batcat`, `fd` → `fdfind`
- **pipx** + **tldr**
- **JetBrainsMono** Nerd Font

Afterward: `source ~/.bashrc` (or open a new shell), then pick **JetBrainsMono Nerd Font** in the terminal if needed.

### `setup-network.sh`

Interactive static IPv4 setup (netplan drop-in, with nmcli fallback).

```bash
chmod +x setup-network.sh
./setup-network.sh
```

Prompts for interface, connection name, IP (CIDR; bare IP gets `/24`), gateway, and primary/secondary DNS. Validates input and confirms before applying.

- **Netplan:** writes `/etc/netplan/99-static-<iface>.yaml` (does not overwrite other YAML), `chmod 600`, apply, optional NM connection rename
- **Fallback:** nmcli manual IPv4, clears `*.lease` only, restarts NetworkManager, brings the connection up

Wrong IP/gateway can lock you out of SSH — confirm values carefully.

### `tools/show_colors.sh`

Prints terminal color codes (standard, background, 256-color) for reference.
