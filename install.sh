#!/usr/bin/env bash
set -e

TARGET_DIR="$HOME/.tmux/alideskram"
SCRIPTS_DIR="$HOME/.tmux"
TMUX_CONF="$HOME/.tmux.conf"
ZSHRC="$HOME/.zshrc"
FONT_NAME="3270 Nerd Font Mono"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/3270.zip"

echo "🚀 Installing Alideskram Tmux Theme..."

# Create target directory
mkdir -p "$TARGET_DIR"

# Copy theme files (excluding install.sh itself)
cp -r deskram.tmux lib main.sh plugins "$TARGET_DIR"

# Copy the entire 'scripts' directory to the target location
cp -r scripts "$SCRIPTS_DIR"

# ✅ Add execute permissions to all necessary scripts
chmod +x "$TARGET_DIR/deskram.tmux"
chmod +x "$TARGET_DIR/main.sh"
find "$TARGET_DIR/plugins" -type f -name "*.sh" -exec chmod +x {} \;
find "$SCRIPTS_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;

# Backup existing .tmux.conf if it exists
if [ -f "$TMUX_CONF" ]; then
    cp "$TMUX_CONF" "$TMUX_CONF.bak"
    echo "📦 Existing .tmux.conf backed up to $TMUX_CONF.bak"
fi

# Copy new .tmux.conf
cp .tmux.conf "$TMUX_CONF"
echo "✔ Theme installed to $TARGET_DIR"
echo "✔ Config installed to $TMUX_CONF"

# Ask user if they want to auto-start tmux in zsh
read -p "Do you want to enable auto-start tmux in Zsh (Termux)? [y/N] " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    AUTO_START='
# Auto-start tmux in Termux
if [ -z "$TMUX" ] && [ -z "$TMUX_STARTED" ]; then
  export TMUX_STARTED=1
  exec tmux new-session || exit
fi
'
    if ! grep -q "TMUX_STARTED" "$ZSHRC" 2>/dev/null; then
        echo "$AUTO_START" >> "$ZSHRC"
        echo "✔ Added auto-start tmux config to $ZSHRC"
    else
        echo "ℹ Auto-start tmux config already exists in $ZSHRC"
    fi
else
    echo "ℹ Skipped adding auto-start tmux config."
fi

# Detect OS
case "$(uname -s)" in
    Linux*)   OS="Linux" ;;
    Darwin*)  OS="macOS" ;;
    *)        echo "❌ Unsupported OS: $(uname -s)"; exit 1 ;;
esac

# Font installation
echo "🔎 Checking for $FONT_NAME..."
if fc-list | grep -qi "3270 Nerd Font Mono"; then
    echo "✔ $FONT_NAME already installed."
else
    echo "⚡ $FONT_NAME not found."
    echo "Where do you want to install the font?"
    echo "  1) For current user only (no sudo)"
    echo "  2) For all users (requires sudo)"
    read -p "Choose [1/2]: " font_choice

    if [[ "$OS" == "Linux" ]]; then
        if [[ "$font_choice" == "2" ]]; then
            FONT_DIR="/usr/share/fonts"
            echo "🔑 Installing font system-wide (requires sudo)..."
            sudo mkdir -p "$FONT_DIR"
            tmp_zip="/tmp/3270.zip"
            curl -L -o "$tmp_zip" "$FONT_URL"
            sudo unzip -o "$tmp_zip" -d "$FONT_DIR"
            rm "$tmp_zip"
            sudo fc-cache -fv > /dev/null
        else
            FONT_DIR="$HOME/.local/share/fonts"
            mkdir -p "$FONT_DIR"
            tmp_zip="/tmp/3270.zip"
            curl -L -o "$tmp_zip" "$FONT_URL"
            unzip -o "$tmp_zip" -d "$FONT_DIR"
            rm "$tmp_zip"
            fc-cache -fv > /dev/null
        fi
    elif [[ "$OS" == "macOS" ]]; then
        FONT_DIR="$HOME/Library/Fonts"
        mkdir -p "$FONT_DIR"
        tmp_zip="/tmp/3270.zip"
        curl -L -o "$tmp_zip" "$FONT_URL"
        unzip -o "$tmp_zip" -d "$FONT_DIR"
        rm "$tmp_zip"
        echo "ℹ On macOS, fonts are per-user only."
    fi

    echo "✔ $FONT_NAME installed to $FONT_DIR"
fi

echo
echo "🎉 Installation complete!"
echo "   Reload tmux to see the theme."
echo "   If you still see squares/question marks instead of icons, set your terminal font to:"
echo "   👉 $FONT_NAME"
