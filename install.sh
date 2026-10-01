#!/bin/bash
set -Eeuo pipefail

# The public install command is "curl ... | bash". Re-exec a complete local
# copy immediately so no child process can consume the script's stdin stream.
if [ "${BUB_INSTALLER_REEXEC:-0}" != "1" ] && [ ! -t 0 ]; then
    SELF="/tmp/bub-installer.$$.sh"
    curl -fsSL "https://raw.githubusercontent.com/hoabba3i-dev/bub-tunnel-releases/main/install.sh" -o "$SELF" || exit 1
    chmod 700 "$SELF"
    BUB_INSTALLER_REEXEC=1 exec bash "$SELF" </dev/null
fi

OWNER="hoabba3i-dev"
REPO_NAME="bub-tunnel-releases"
REPO="https://github.com/${OWNER}/${REPO_NAME}"
API="https://api.github.com/repos/${OWNER}/${REPO_NAME}"
LATEST_URL="${REPO}/releases/latest"
INSTALL_DIR="/opt/bub-tunnel"
BIN_DIR="/usr/local/bin"

TMP=""
cleanup() {
    if [ -n "${TMP:-}" ] && [ -d "${TMP:-}" ]; then
        rm -rf "$TMP"
    fi
    return 0
}
trap cleanup EXIT

red='\033[31m'; yellow='\033[33m'; green='\033[32m'; reset='\033[0m'
progress() {
    local pct="$1" msg="$2" color="$yellow" filled empty bar
    if [ "$pct" -ge 100 ]; then
        color="$green"
    fi
    filled=$((pct/5))
    empty=$((20-filled))
    bar=""
    while [ "$filled" -gt 0 ]; do
        bar="${bar}#"
        filled=$((filled-1))
    done
    while [ "$empty" -gt 0 ]; do
        bar="${bar}-"
        empty=$((empty-1))
    done
    printf "\r%b[%s] %3d%%  %s%b" "$color" "$bar" "$pct" "$msg" "$reset"
    if [ "$pct" -ge 100 ]; then
        printf "\n"
    fi
    return 0
}
die() {
    printf "
%b[FAILED]%b %s
" "$red" "$reset" "$*" >&2
    exit 1
}

[ "$(id -u)" = "0" ] || die "Please run as root."
export DEBIAN_FRONTEND=noninteractive

progress 5 "Preparing installer"
APT_LOG="/tmp/bub-installer-apt.log"
if ! apt-get update -qq </dev/null >"$APT_LOG" 2>&1; then
    tail -n 25 "$APT_LOG" >&2 || true
    die "Package index update failed"
fi
if ! apt-get install -y -qq ca-certificates curl iproute2 iptables tar python3 </dev/null >>"$APT_LOG" 2>&1; then
    tail -n 25 "$APT_LOG" >&2 || true
    die "Required package installation failed"
fi
rm -f "$APT_LOG"
progress 10 "Requirements ready"

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64) RELEASE_ARCH="amd64" ;;
    arm64) RELEASE_ARCH="arm64" ;;
    *) die "Unsupported architecture: $ARCH" ;;
esac

progress 15 "Finding latest release"
LATEST_EFFECTIVE="$(curl -fsSL --retry 3 --retry-delay 1 -o /dev/null -w '%{url_effective}' "$LATEST_URL")"
REPO_REF="${LATEST_EFFECTIVE##*/}"
[[ "$REPO_REF" =~ ^(v\.?)?[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Could not determine latest release"

ASSET_CANDIDATES=(
    "bub-${REPO_REF}-linux-${RELEASE_ARCH}.tar.gz"
    "BUB-${REPO_REF}-linux-${RELEASE_ARCH}.tar.gz"
)

TMP="$(mktemp -d /tmp/bub-install.XXXXXX)"
mkdir -p "$TMP/extracted"

progress 25 "Reading release metadata"
RELEASE_JSON="$TMP/release.json"
curl -fsSL --retry 3 --retry-delay 1     -H "Accept: application/vnd.github+json"     "$API/releases/tags/$REPO_REF" -o "$RELEASE_JSON" || die "Could not read GitHub release metadata"

ASSET_NAME=""
ASSET_URL=""
EXPECTED_SHA=""

for CANDIDATE in "${ASSET_CANDIDATES[@]}"; do
    META="$(python3 - "$RELEASE_JSON" "$CANDIDATE" <<'PY'
import json,sys
p,n=sys.argv[1:]
d=json.load(open(p))
for a in d.get("assets",[]):
    if a.get("name")==n:
        print(a.get("browser_download_url",""))
        print(a.get("digest",""))
        break
PY
)" || true
    URL="$(printf '%s
' "$META" | sed -n '1p')"
    DIGEST="$(printf '%s
' "$META" | sed -n '2p')"
    if [ -n "$URL" ]; then
        ASSET_NAME="$CANDIDATE"
        ASSET_URL="$URL"
        EXPECTED_SHA="${DIGEST#sha256:}"
        break
    fi
done

[ -n "$ASSET_NAME" ] || die "No compatible release asset for $REPO_REF / $RELEASE_ARCH"
[[ "$EXPECTED_SHA" =~ ^[0-9a-fA-F]{64}$ ]] || die "GitHub release asset has no valid SHA256 digest"

progress 35 "Downloading $REPO_REF"
curl -fsSL --retry 5 --retry-delay 2 --retry-all-errors     "$ASSET_URL" -o "$TMP/release.tar.gz" || die "Release download failed"

progress 55 "Verifying release"
ACTUAL_SHA="$(sha256sum "$TMP/release.tar.gz" | awk '{print $1}')"
[ "${ACTUAL_SHA,,}" = "${EXPECTED_SHA,,}" ] || die "Release SHA256 verification failed"

MEMBERS="$TMP/members"
tar -tzf "$TMP/release.tar.gz" | sed '/\/$/d' | sort > "$MEMBERS"
EXPECTED="$TMP/expected"
printf '%s
' bub bub-client bub-server bub-control-center bub-manager.sh | sort > "$EXPECTED"
cmp -s "$EXPECTED" "$MEMBERS" || die "Unexpected release archive contents"

progress 65 "Extracting verified release"
tar -xzf "$TMP/release.tar.gz" -C "$TMP/extracted"

for BIN in bub bub-server bub-client bub-control-center; do
    SRC_BIN="$TMP/extracted/$BIN"
    [ -f "$SRC_BIN" ] || die "$BIN not found in release"
    chmod 755 "$SRC_BIN"
    case "$BIN" in
        bub) BIN_BUB="$SRC_BIN" ;;
        bub-server) BIN_SERVER="$SRC_BIN" ;;
        bub-client) BIN_CLIENT="$SRC_BIN" ;;
        bub-control-center) BIN_CONTROL="$SRC_BIN" ;;
    esac
done

progress 75 "Backing up current binaries"
mkdir -p "$INSTALL_DIR" /etc/bub-tunnel /var/log/bub-tunnel "$INSTALL_DIR/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$INSTALL_DIR/backups/$STAMP"
mkdir -p "$BACKUP_DIR"
for BIN in bub bub-server bub-client bub-control-center; do
    [ ! -f "$BIN_DIR/$BIN" ] || cp -a "$BIN_DIR/$BIN" "$BACKUP_DIR/$BIN"
done

progress 85 "Installing BUB"
install -m 755 "$BIN_SERVER" "$BIN_DIR/bub-server.new"
install -m 755 "$BIN_CLIENT" "$BIN_DIR/bub-client.new"
install -m 755 "$BIN_BUB" "$BIN_DIR/bub.new"
install -m 755 "$BIN_CONTROL" "$BIN_DIR/bub-control-center.new"
mv -f "$BIN_DIR/bub-server.new" "$BIN_DIR/bub-server"
mv -f "$BIN_DIR/bub-client.new" "$BIN_DIR/bub-client"
mv -f "$BIN_DIR/bub.new" "$BIN_DIR/bub"
mv -f "$BIN_DIR/bub-control-center.new" "$BIN_DIR/bub-control-center"

BIN_MANAGER="$TMP/extracted/bub-manager.sh"
if [ -f "$BIN_MANAGER" ]; then
    install -m 755 "$BIN_MANAGER" "$INSTALL_DIR/bub-manager.sh"
    install -m 755 "$INSTALL_DIR/bub-manager.sh" "$BIN_DIR/bub-manager"
else
    ln -sfn "$BIN_DIR/bub" "$BIN_DIR/bub-manager"
fi

NORMALIZED_VERSION="${REPO_REF#v}"
NORMALIZED_VERSION="${NORMALIZED_VERSION#.}"
printf '%s
' "$NORMALIZED_VERSION" > "$INSTALL_DIR/VERSION"
hash -r 2>/dev/null || true

progress 100 "BUB Tunnel $REPO_REF installed"
echo
if [ -r /dev/tty ] && [ -w /dev/tty ]; then
    exec </dev/tty >/dev/tty 2>&1
    stty sane 2>/dev/null || true
    read -r -p "Press Enter to open BUB Manager..." _ || true
    stty sane 2>/dev/null || true
    "$BIN_DIR/bub"
    exit $?
fi
printf '%s\n' "Installation complete. Run: bub"
