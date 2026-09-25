#!/bin/sh

set -eu

install -d "$HOME/.local/bin" "$HOME/.config/environment.d"

# GDM launches this script directly; zsh startup files are not involved.
install -m 0755 /dev/stdin "$HOME/.local/bin/start-sway" <<'EOF'
#!/bin/sh

export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM="wayland;xcb"
export GDK_BACKEND="wayland,x11"
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export ELECTRON_OZONE_PLATFORM_HINT=wayland

export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

exec /usr/bin/sway "$@"
EOF

# Give systemd user services and D-Bus activated apps the toolkit settings.
install -m 0644 /dev/stdin "$HOME/.config/environment.d/90-wayland.conf" <<'EOF'
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland;xcb
GDK_BACKEND=wayland,x11
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
ELECTRON_OZONE_PLATFORM_HINT=wayland
EOF

# The session entry must point to the launcher rather than sway itself.
sudo install -m 0644 /dev/stdin /usr/share/wayland-sessions/sway.desktop <<EOF
[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=$HOME/.local/bin/start-sway
Type=Application
DesktopNames=sway
EOF
