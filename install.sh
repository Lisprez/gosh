#!/bin/sh
# Gosh (GhostShell) Automated Installer
# https://github.com/Lisprez/gosh

set -e

REPO="Lisprez/gosh"
BINARY_NAME="gosh"

# 1. Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin)
        case "$ARCH" in
            arm64) TARGET="gosh-darwin-arm64" ;;
            x86_64) TARGET="gosh-darwin-x86_64" ;;
            *) echo "Unsupported architecture on macOS: $ARCH"; exit 1 ;;
        esac
        ;;
    Linux)
        case "$ARCH" in
            x86_64|amd64) TARGET="gosh-linux-x86_64" ;;
            aarch64|arm64) TARGET="gosh-linux-aarch64" ;;
            *) echo "Unsupported architecture on Linux: $ARCH"; exit 1 ;;
        esac
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# 2. Determine install directory
if [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -n "$HOME" ] && [ -d "$HOME/.local/bin" ]; then
    INSTALL_DIR="$HOME/.local/bin"
elif [ -n "$HOME" ]; then
    mkdir -p "$HOME/.local/bin"
    INSTALL_DIR="$HOME/.local/bin"
else
    INSTALL_DIR="/usr/local/bin"
fi

DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${TARGET}"

echo "👻 Downloading Gosh for ${OS} (${ARCH})..."
TMP_FILE="$(mktemp /tmp/gosh.XXXXXX)"

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_FILE" "$DOWNLOAD_URL"
else
    echo "Error: curl or wget is required to download Gosh."
    exit 1
fi

chmod +x "$TMP_FILE"

# 3. Move binary to target directory
DEST="${INSTALL_DIR}/${BINARY_NAME}"

echo "📦 Installing binary to ${DEST}..."
if [ -w "$INSTALL_DIR" ]; then
    mv "$TMP_FILE" "$DEST"
else
    sudo mv "$TMP_FILE" "$DEST"
fi

echo "✨ Gosh successfully installed to ${DEST}!"
echo ""
echo "Try running:"
echo "    ${BINARY_NAME} -c \"echo 'The Ghost now has a Shell.'\""
