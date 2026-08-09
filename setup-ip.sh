#!/usr/bin/env bash

# Abort on error, unset variables, or failed pipelines
set -euo pipefail

IFACE="eth0"
CONN_NAME="ethernet0"

is_ipv4() {
  [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  local IFS=.
  read -r a b c d <<< "$1"
  (( a<=255 && b<=255 && c<=255 && d<=255 ))
}

is_cidr() {
  # ${var%pattern} >> trim matching suffix from the end
  # ${var#pattern} >> trim matching prefix from the start
  local ip=${1%/*} prefix=${1#*/}
  [[ $1 == */* ]] || return 1
  is_ipv4 "$ip" || return 1
  [[ $prefix =~ ^[0-9]+$ ]] && (( prefix>=0 && prefix<=32 ))
}

read -rp "IP address (e.g. 192.168.1.30/24): " IP_ADDR
read -rp "Gateway (e.g. 192.168.1.1): " GATEWAY
read -rp "Primary DNS (e.g. 8.8.8.8): " DNS
read -rp "Seconary DNS (e.g. 1.1.1.1): " SND_DNS

if [[ -z "$IP_ADDR" || -z "$GATEWAY" || -z "$DNS" || -z "$SND_DNS" ]]; then
  echo "IP, gateway, and DNS and SND_DNS are required."
  exit 1
fi

[[ $IP_ADDR == */* ]] || IP_ADDR="${IP_ADDR}/24"

if ! is_cidr "$IP_ADDR"; then
  echo "IP must be CIDR form, e.g. 192.168.1.30/24"
  exit 1
fi
if ! is_ipv4 "$GATEWAY"; then
  echo "Gateway must be an IPv4 address, e.g. 192.168.1.1"
  exit 1
fi
if ! is_ipv4 "$DNS"; then
  echo "DNS must be an IPv4 address, e.g. 8.8.8.8"
  exit 1
fi
if ! is_ipv4 "$SND_DNS"; then
  echo "SND_DNS must be an IPv4 address, e.g. 1.1.1.1"
  exit 1
fi

echo "Using IP=$IP_ADDR Gateway=$GATEWAY DNS=$DNS on $IFACE"

read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0


apply_netplan() {
    # Function: apply static IP via netplan
    NETPLAN_FILE=$(ls /etc/netplan/*.yaml 2>/dev/null | head -n1)
    if [ -z "$NETPLAN_FILE" ]; then
        echo "No netplan config found."
        return 1
    fi

    echo "Using netplan config file: $NETPLAN_FILE"
    sudo cp "$NETPLAN_FILE" "${NETPLAN_FILE}.bak"
    echo "Backup saved as ${NETPLAN_FILE}.bak"

    # Set safe permissions on /etc/netplan YAML
    sudo chmod 600 "$NETPLAN_FILE"
    sudo chown root:root "$NETPLAN_FILE"

    # Generate new static IP config
    sudo tee "$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    $IFACE:
      dhcp4: no
      addresses:
        - $IP_ADDR
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [$DNS, $SND_DNS]
EOF

    # Ensure permissions after editing
    sudo chmod 600 "$NETPLAN_FILE"
    sudo chown root:root "$NETPLAN_FILE"

    # Apply netplan (suppress harmless permission warnings)
    sudo netplan generate 2>/dev/null
    sudo netplan apply 2>/dev/null

    echo "Netplan applied successfully. Waiting for NetworkManager to start..."
    # Wait up to 15 seconds for NetworkManager to become active
    timeout=15
    while ! systemctl is-active --quiet NetworkManager && [ $timeout -gt 0 ]; do
        sleep 1
        timeout=$((timeout-1))
    done

    if ! systemctl is-active --quiet NetworkManager; then
        echo "Error: NetworkManager did not start in time."
        return 1
    fi

    # Rename the NetworkManager connection to match CONN_NAME
    CURRENT_CONN=$(nmcli -t -f GENERAL.CONNECTION device show $IFACE | cut -d: -f2)
    if [ -n "$CURRENT_CONN" ] && [ "$CURRENT_CONN" != "$CONN_NAME" ]; then
        echo "Renaming connection '$CURRENT_CONN' → '$CONN_NAME'"
        sudo nmcli connection modify "$CURRENT_CONN" connection.id "$CONN_NAME"
        sudo nmcli connection down "$CONN_NAME"
        sudo nmcli connection up "$CONN_NAME"
    fi

    echo "Current IP on $IFACE:"
    ip a show $IFACE | grep "inet " || true
    return 0
}

apply_nmcli() {
    # Function: apply static IP via nmcli (baseline)
    # Get the connection profile bound to the interface
    CONN=$(nmcli -t -f GENERAL.CONNECTION device show $IFACE | cut -d: -f2)

    if [ -z "$CONN" ]; then
        echo "No active connection found for $IFACE"
        return 1
    fi

    echo "Found connection: $CONN"

    # Rename the connection
    sudo nmcli connection modify "$CONN" connection.id "$CONN_NAME"

    # Ensure autoconnect
    sudo nmcli connection modify "$CONN_NAME" connection.autoconnect yes

    # Configure static IP
    sudo nmcli connection modify "$CONN_NAME" \
      connection.interface-name "$IFACE" \
      ipv4.method manual \
      ipv4.addresses "$IP_ADDR" \
      ipv4.gateway "$GATEWAY" \
      ipv4.dns "$DNS $SND_DNS" \
      ipv4.ignore-auto-dns yes \
      ipv4.ignore-auto-routes yes \
      ipv6.method ignore

    # Remove stored DHCP leases
    sudo rm -rf /var/lib/NetworkManager/*

    # Restart NetworkManager
    sudo systemctl restart NetworkManager

    # Bring the connection up
    sudo nmcli connection up "$CONN_NAME"

    echo "nmcli static IP applied. Current IP:"
    ip a show $IFACE | grep "inet " || true
    return 0
}

# Main
if [ -d /etc/netplan ] && [ "$(ls -A /etc/netplan)" ]; then
    echo "Netplan detected. Applying static IP via netplan..."
    apply_netplan || { echo "Netplan failed, falling back to nmcli..."; apply_nmcli; }
else
    echo "No netplan detected. Applying static IP via nmcli..."
    apply_nmcli
fi
