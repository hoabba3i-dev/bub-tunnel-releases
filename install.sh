#!/bin/bash
set -euo pipefail

OWNER="hoabba3i-dev"
REPO_NAME="bub-tunnel-releases"
REPO="https://github.com/${OWNER}/${REPO_NAME}"
LATEST_URL="${REPO}/releases/latest"
INSTALL_DIR="/opt/bub-tunnel"
BIN_DIR="/usr/local/bin"

cleanup() {
    if [ -n "${TMP:-}" ] && [ -d "${TMP:-}" ]; then
        rm -rf "$TMP"
    fi
}
trap cleanup EXIT

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
    amd64) RELEASE_ARCH="amd64" ;;
    arm64) RELEASE_ARCH="arm64" ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

LATEST_EFFECTIVE="$(curl -fsSL -o /dev/null -w '%{url_effective}' "$LATEST_URL")"
REPO_REF="${LATEST_EFFECTIVE##*/}"

# Accept canonical X.Y.Z plus historical vX.Y.Z and v.X.Y.Z tags.
if [[ ! "$REPO_REF" =~ ^(v\.?)?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Could not determine latest BUB release from: $LATEST_EFFECTIVE"
    exit 1
fi

# Support both historical lowercase assets (bub-vX.Y.Z-...) and newer
# uppercase assets (BUB-X.Y.Z-...). Prefer the historical form first so the
# v0.90.3 bridge release remains installable by the same convention as v0.90.2.
ASSET_CANDIDATES=(
    "bub-${REPO_REF}-linux-${RELEASE_ARCH}.tar.gz"
    "BUB-${REPO_REF}-linux-${RELEASE_ARCH}.tar.gz"
)

echo "[2/5] Preparing BUB $REPO_REF..."

TMP="$(mktemp -d /tmp/bub-install.XXXXXX)"
mkdir -p "$TMP/extracted"

echo "[3/5] Downloading BUB..."
ASSET_NAME=""
for CANDIDATE in "${ASSET_CANDIDATES[@]}"; do
    ASSET_URL="${REPO}/releases/download/${REPO_REF}/${CANDIDATE}"
    echo "Trying asset: $CANDIDATE"
    if curl -fL --retry 2 --retry-delay 1 "$ASSET_URL" -o "$TMP/release.tar.gz"; then
        ASSET_NAME="$CANDIDATE"
        break
    fi
done
if [ -z "$ASSET_NAME" ]; then
    echo "ERROR: No compatible release asset found for $REPO_REF / $RELEASE_ARCH"
    exit 1
fi
echo "Asset: $ASSET_NAME"

echo "[4/5] Installing BUB binaries..."
tar -xzf "$TMP/release.tar.gz" -C "$TMP/extracted"

for BIN in bub bub-server bub-client bub-control-center; do
    SRC_BIN="$(find "$TMP/extracted" -type f -name "$BIN" -print -quit)"
    if [ -z "$SRC_BIN" ]; then
        echo "ERROR: $BIN not found in release."
        exit 1
    fi
    chmod 755 "$SRC_BIN"
    case "$BIN" in
        bub) BIN_BUB="$SRC_BIN" ;;
        bub-server) BIN_SERVER="$SRC_BIN" ;;
        bub-client) BIN_CLIENT="$SRC_BIN" ;;
        bub-control-center) BIN_CONTROL="$SRC_BIN" ;;
    esac
done

mkdir -p "$INSTALL_DIR" /etc/bub-tunnel /var/log/bub-tunnel "$INSTALL_DIR/backups"

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$INSTALL_DIR/backups/$STAMP"
mkdir -p "$BACKUP_DIR"

for BIN in bub bub-server bub-client bub-control-center; do
    if [ -f "$BIN_DIR/$BIN" ]; then
        cp -a "$BIN_DIR/$BIN" "$BACKUP_DIR/$BIN"
    fi
done

install -m 755 "$BIN_SERVER" "$BIN_DIR/bub-server.new"
install -m 755 "$BIN_CLIENT" "$BIN_DIR/bub-client.new"
install -m 755 "$BIN_BUB" "$BIN_DIR/bub.new"
install -m 755 "$BIN_CONTROL" "$BIN_DIR/bub-control-center.new"

mv -f "$BIN_DIR/bub-server.new" "$BIN_DIR/bub-server"
mv -f "$BIN_DIR/bub-client.new" "$BIN_DIR/bub-client"
mv -f "$BIN_DIR/bub.new" "$BIN_DIR/bub"
mv -f "$BIN_DIR/bub-control-center.new" "$BIN_DIR/bub-control-center"

# Install the compatibility manager wrapper when it is bundled in the release.
# Fall back to a symlink for compatibility with older binary-only archives.
BIN_MANAGER="$(find "$TMP/extracted" -type f -name 'bub-manager.sh' -print -quit)"
if [ -n "$BIN_MANAGER" ]; then
    install -m 755 "$BIN_MANAGER" "$INSTALL_DIR/bub-manager.sh"
    install -m 755 "$INSTALL_DIR/bub-manager.sh" "$BIN_DIR/bub-manager"
else
    ln -sfn "$BIN_DIR/bub" "$BIN_DIR/bub-manager"
fi

NORMALIZED_VERSION="${REPO_REF#v}"
NORMALIZED_VERSION="${NORMALIZED_VERSION#.}"
printf "%s\n" "$NORMALIZED_VERSION" > "$INSTALL_DIR/VERSION"

hash -r 2>/dev/null || true

echo "[5/5] Installation completed."
echo
echo "======================================"
echo "       BUB Tunnel installed"
echo "======================================"
echo
echo "Version : $REPO_REF"
echo "BUB     : $BIN_DIR/bub"
echo "Server  : $BIN_DIR/bub-server"
echo "Client  : $BIN_DIR/bub-client"
echo "Control : $BIN_DIR/bub-control-center"
echo
echo "Installed files:"
ls -lh "$BIN_DIR/bub" "$BIN_DIR/bub-server" "$BIN_DIR/bub-client" "$BIN_DIR/bub-control-center"
echo
echo "Run:"
echo "  bub"
echo
