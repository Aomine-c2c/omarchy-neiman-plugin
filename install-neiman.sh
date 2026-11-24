#!/usr/bin/env bash
# ==============================================================================
# NEIMAN Autonomous OS — Omarchy Plugin Full Application Installer & Bootstrapper
# ==============================================================================
# Triggered only on explicit user action from the Omarchy bar panel or terminal.
# Installs user-space binaries into ~/.local/bin without requiring root privileges.
# ==============================================================================

set -euo pipefail

VERSION="1.3.0"
RELEASE_BASE="https://github.com/Aomine-c2c/Neiman/releases/latest/download"
BIN_DIR="${HOME}/.local/bin"
APPS_DIR="${HOME}/.local/share/applications"

mkdir -p "${BIN_DIR}" "${APPS_DIR}"

echo "================================================================="
echo "  NEIMAN Autonomous OS — Full Application Installer (v${VERSION})"
echo "================================================================="

# 1. If local source repo exists, delegate to scripts/install.sh
if [[ -x "${HOME}/Projects/Sila/scripts/install.sh" ]]; then
    echo "[*] Local NEIMAN workspace detected at ~/Projects/Sila. Running scripts/install.sh --skip-build..."
    bash "${HOME}/Projects/Sila/scripts/install.sh" --skip-build
    echo "[+] NEIMAN installed and ready. Launch with 'neiman-desktop' or 'neiman-cli'."
    exit 0
fi

# 2. Otherwise download verified v1.3.0 release setups from Aomine-c2c/Neiman
echo "[*] Downloading NEIMAN Desktop AppImage & Standalone Rust TUI (v${VERSION})..."
curl -fL "${RELEASE_BASE}/NEIMAN-desktop_${VERSION}_amd64.AppImage" -o "${BIN_DIR}/neiman-desktop"
curl -fL "${RELEASE_BASE}/neiman-tui-linux-x86_64" -o "${BIN_DIR}/neiman-cli"
chmod +x "${BIN_DIR}/neiman-desktop" "${BIN_DIR}/neiman-cli"

cat << EOF > "${APPS_DIR}/neiman.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=NEIMAN
GenericName=Autonomous Organization OS
Comment=NEIMAN — Multi-Agent Autonomous Organization Operating System
Exec=${BIN_DIR}/neiman-desktop
Icon=neiman
Terminal=false
Categories=Development;Office;Utility;
StartupNotify=true
EOF

chmod +x "${APPS_DIR}/neiman.desktop"
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${APPS_DIR}" 2>/dev/null || true
fi

echo "[+] NEIMAN v${VERSION} installed to ${BIN_DIR}/neiman-desktop and ${BIN_DIR}/neiman-cli."
