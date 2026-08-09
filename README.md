# setup-linux

Bootstrap scripts for a Debian/Ubuntu-style Linux box: CLI tools, aliases, fonts, optional static IP, and Raspberry Pi tweaks.

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

## Raspberry Pi (`raspberry/`)

### `setup-raspberry-config.sh` / `uninstall-raspberry-config.sh`

Installs `raspberry/config.txt` to `/boot/firmware/config.txt` (backs up the live file to `config.txt.bak` with the same ownership/mode via `install`). Uninstall restores the backup.

```bash
chmod +x raspberry/setup-raspberry-config.sh raspberry/uninstall-raspberry-config.sh
./raspberry/setup-raspberry-config.sh
./raspberry/uninstall-raspberry-config.sh
```

Requires a local `raspberry/config.txt` next to the installer.

### `setup-swappiness.sh`

Installs `99-swappiness.conf` to `/etc/sysctl.d/` and applies it (`vm.swappiness=10`, lower cache pressure / page-cluster).

```bash
chmod +x raspberry/setup-swappiness.sh
./raspberry/setup-swappiness.sh
```

### `setup-cpu-governor-service.sh` / `uninstall-cpu-governor-service.sh`

Installs a oneshot systemd unit that sets the CPU frequency governor to `performance` at boot. Uninstall disables/stops the unit and removes it.

```bash
chmod +x raspberry/setup-cpu-governor-service.sh raspberry/uninstall-cpu-governor-service.sh
./raspberry/setup-cpu-governor-service.sh
./raspberry/uninstall-cpu-governor-service.sh
```

### `99-tailscale.conf`

Sysctl drop-in for Tailscale exit-node IP forwarding (`ip_forward` / IPv6 forwarding). Copy to `/etc/sysctl.d/` and run `sudo sysctl --system` when using the Pi as an exit node.

## Tools

### `tools/show_colors.sh`

Prints terminal color codes (standard, background, 256-color) for reference.

### `tools/setup-sensor.sh`

Installs `lm-sensors`, runs `sensors-detect`, then prints sensor readings.
