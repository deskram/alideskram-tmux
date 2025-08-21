#!/usr/bin/env bash
# Cross-platform (Linux/macOS) network tile for alideskram
# Shows type + IP (Wi-Fi SSID / Ethernet iface / VPN iface) based on @alideskram-network-display
# Values: "ip" | "type" | "type+ip" (default: type+ip)

set -euo pipefail
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

# Icons (override from tmux.conf if تبي)
ethernet_icon=$(get_tmux_option "@alideskram-network-ethernet-icon" "󰈀")
wifi_icon=$(get_tmux_option "@alideskram-network-wifi-icon" "")
vpn_icon=$(get_tmux_option "@alideskram-network-vpn-icon" "")
offline_icon=$(get_tmux_option "@alideskram-network-offline-icon" "󰌙")

display=$(get_tmux_option "@alideskram-network-display" "type+ip")

# ---------- helpers ----------
trim() { awk '{$1=$1};1'; }

linux_default_iface() {
  ip route get 1.1.1.1 2>/dev/null \
   | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}'
}

linux_ipv4_of() {
  local iface="$1"
  ip -o -4 addr show dev "$iface" 2>/dev/null \
    | awk '{print $4}' | cut -d/ -f1 | head -n1
}

linux_wifi_ssid() { iwgetid -r 2>/dev/null || true; }

mac_default_iface() {
  route -n get default 2>/dev/null | awk '/interface:/{print $2}'
}

mac_ipv4_of() {
  local iface="$1"
  ipconfig getifaddr "$iface" 2>/dev/null || true
}

mac_wifi_dev() {
  networksetup -listallhardwareports 2>/dev/null \
    | awk '/Wi-Fi/{getline; if($1=="Device:") print $2}'
}

mac_wifi_ssid() {
  local dev; dev="$(mac_wifi_dev)"
  [ -n "${dev:-}" ] || { echo ""; return; }
  networksetup -getairportnetwork "$dev" 2>/dev/null | awk -F': ' '{print $2}'
}

# Find first VPN-like interface that has an IPv4
find_vpn_iface() {
  case "$(uname -s)" in
    Linux)
      ip -o link show 2>/dev/null | awk -F': ' '{print $2}' \
        | grep -E '^(wg|tun|tap|ppp|tailscale|zt|vpn)[0-9]*$' | while read -r i; do
            ip=$(linux_ipv4_of "$i")
            [ -n "$ip" ] && { echo "$i"; return; }
          done
      ;;
    Darwin)
      ifconfig -l 2>/dev/null | tr ' ' '\n' \
        | grep -E '^(utun|tun|tap|wg|ppp|tailscale)[0-9]*$' | while read -r i; do
            ip=$(ifconfig "$i" 2>/dev/null | awk '/inet /{print $2; exit}')
            [ -n "$ip" ] && { echo "$i"; return; }
          done
      ;;
  esac
}

ipv4_of() {
  local iface="$1"
  case "$(uname -s)" in
    Linux)  linux_ipv4_of "$iface" ;;
    Darwin) ifconfig "$iface" 2>/dev/null | awk '/inet /{print $2; exit}' ;;
    *) echo "" ;;
  esac
}

# ---------- main ----------
main() {
  local os iface ip label icon ssid

  # Prefer VPN if up
  iface="$(find_vpn_iface || true)"
  if [ -n "${iface:-}" ]; then
    ip="$(ipv4_of "$iface")"
    label="VPN $iface"
    icon="$vpn_icon"
  else
    case "$(uname -s)" in
      Linux)
        ssid="$(linux_wifi_ssid)"
        iface="$(linux_default_iface)"
        if [ -n "${ssid:-}" ]; then
          icon="$wifi_icon"
          label="$ssid"
        else
          icon="$ethernet_icon"
          label="${iface:-Eth}"
        fi
        ip="$( [ -n "${iface:-}" ] && linux_ipv4_of "$iface" || echo "" )"
        ;;
      Darwin)
        local wdev; wdev="$(mac_wifi_dev)"
        local wssid; wssid="$(mac_wifi_ssid)"
        iface="$(mac_default_iface)"
        if [ -n "${wssid:-}" ]; then
          icon="$wifi_icon"
          label="$wssid"
        else
          icon="$ethernet_icon"
          label="${iface:-Eth}"
        fi
        ip="$( [ -n "${iface:-}" ] && mac_ipv4_of "$iface" || echo "" )"
        ;;
      *) icon="$offline_icon"; label="Offline"; ip="";;
    esac
  fi

  # If completely offline (no ip anywhere)
  if [ -z "${ip:-}" ] && [ -z "${iface:-}" ]; then
    echo "$offline_icon Offline"
    exit 0
  fi

  case "$display" in
    ip)          out="${ip:-N/A}" ;;
    type)        out="$icon ${label:-N/A}" ;;
    type+ip|*)   out="$icon ${label:-N/A} ${ip:-N/A}" ;;
  esac

  echo "$(echo "$out" | trim)"
}

main
