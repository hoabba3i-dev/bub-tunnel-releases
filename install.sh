#!/bin/bash
set -euo pipefail

REPO="https://github.com/hoabba3i-dev/bub-tunnel-releases"
INSTALL_DIR="/opt/bub-tunnel"

echo "======================================"
echo "        BUB Tunnel Installer"
echo "======================================"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/5] Installing required packages..."
apt-get update
apt-get install -y ca-certificates curl iproute2 iptables tar

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64)
        RELEASE_ARCH="amd64"
        ;;
    arm64)
        RELEASE_ARCH="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Discover the latest release through GitHub's public redirect instead of
# api.github.com. This avoids unauthenticated REST API rate-limit failures.
LATEST_URL="$(curl -4 -fsSL --retry 3 -o /dev/null -w '%{url_effective}' "$REPO/releases/latest")"
REPO_REF="${LATEST_URL##*/}"

if [ -z "$REPO_REF" ] || [ "$REPO_REF" = "latest" ] || [[ "$REPO_REF" != v* ]]; then
    echo "ERROR: Could not determine latest BUB release."
    echo "Resolved URL: $LATEST_URL"
    exit 1
fi

EXPECTED_ASSET="bub-${REPO_REF}-linux-${RELEASE_ARCH}.tar.gz"
ASSET_URL="$REPO/releases/download/${REPO_REF}/${EXPECTED_ASSET}"

echo "[2/5] Preparing BUB $REPO_REF..."
echo "Architecture: $ARCH"
echo "Asset: $EXPECTED_ASSET"

TMP="$(mktemp -d /tmp/bub-install.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/extracted"

echo "[3/5] Downloading BUB..."
curl -4 -fL --retry 3 --retry-delay 1 "$ASSET_URL" -o "$TMP/release.tar.gz"

echo "[4/5] Installing BUB binaries..."
tar -xzf "$TMP/release.tar.gz" -C "$TMP/extracted"

BIN_SERVER="$(find "$TMP/extracted" -type f -name 'bub-server' -print -quit)"
BIN_CLIENT="$(find "$TMP/extracted" -type f -name 'bub-client' -print -quit)"
BIN_BUB="$(find "$TMP/extracted" -type f -name 'bub' -print -quit)"

[ -n "$BIN_SERVER" ] || {
    echo "ERROR: bub-server not found in release."
    exit 1
}

[ -n "$BIN_CLIENT" ] || {
    echo "ERROR: bub-client not found in release."
    exit 1
}

[ -n "$BIN_BUB" ] || {
    echo "ERROR: bub not found in release."
    exit 1
}

mkdir -p "$INSTALL_DIR"
mkdir -p /etc/bub-tunnel
mkdir -p /var/log/bub-tunnel

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$INSTALL_DIR/backups/$STAMP"
mkdir -p "$BACKUP_DIR"

for BIN in bub bub-server bub-client; do
    if [ -f "/usr/local/bin/$BIN" ]; then
        cp -a "/usr/local/bin/$BIN" "$BACKUP_DIR/$BIN"
    fi
done

install -m 755 "$BIN_SERVER" /usr/local/bin/bub-server
install -m 755 "$BIN_CLIENT" /usr/local/bin/bub-client
install -m 755 "$BIN_BUB" /usr/local/bin/bub

# Compatibility command
ln -sf /usr/local/bin/bub /usr/local/bin/bub-manager

cat > "$INSTALL_DIR/bub-manager.sh" <<'EOF'
#!/bin/bash
exec /usr/local/bin/bub "$@"
EOF
chmod 755 "$INSTALL_DIR/bub-manager.sh"

printf "%s\n" "${REPO_REF#v}" > "$INSTALL_DIR/VERSION"

echo "[5/5] Installation completed."
echo
echo "======================================"
echo "       BUB Tunnel installed"
echo "======================================"
echo
echo "Version : $REPO_REF"
echo "BUB     : /usr/local/bin/bub"
echo "Server  : /usr/local/bin/bub-server"
echo "Client  : /usr/local/bin/bub-client"
echo
echo "Run:"
echo "  bub"
echo
