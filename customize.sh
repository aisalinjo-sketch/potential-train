#!/usr/bin/env bash
# Runs INSIDE the Kubuntu chroot. Applies Novaria OS look (CachyOS-like dark + teal accent).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive HOME=/root LC_ALL=C

OS_NAME="Novaria OS"
ACCENT_RGB="0,201,167"     # teal/green accent, change to taste (R,G,B)

echo "-- Installing icons and fonts"
apt-get update
apt-get install -y papirus-icon-theme fonts-inter

echo "-- Branding"
sed -i "s/^NAME=.*/NAME=\"$OS_NAME\"/; s/^PRETTY_NAME=.*/PRETTY_NAME=\"$OS_NAME\"/" /usr/lib/os-release
echo "$OS_NAME \\n \\l" > /etc/issue
echo "$OS_NAME" > /etc/issue.net

echo "-- Color scheme (Breeze Dark with Novaria accent)"
SCHEME_DIR=/usr/share/color-schemes
sed "s/61,174,233/$ACCENT_RGB/g; s/^Name=.*/Name=Novaria Dark/" \
  "$SCHEME_DIR/BreezeDark.colors" > "$SCHEME_DIR/NovariaDark.colors"

echo "-- Default settings for every new user (/etc/skel)"
mkdir -p /etc/skel/.config
cp "$SCHEME_DIR/NovariaDark.colors" /etc/skel/.config/kdeglobals
KW="kwriteconfig5 --file /etc/skel/.config/kdeglobals"
$KW --group General --key ColorScheme NovariaDark
$KW --group Icons --key Theme Papirus-Dark
$KW --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop

echo "-- Default wallpaper"
for d in /usr/share/plasma/look-and-feel/org.kde.breeze.desktop /usr/share/plasma/look-and-feel/org.kde.breezedark.desktop; do
  if [ -f "$d/contents/defaults" ]; then
    sed -i 's/^Image=.*/Image=Novaria/' "$d/contents/defaults"
  fi
done

echo "-- Cleanup"
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /root/.bash_history || true
