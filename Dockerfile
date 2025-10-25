# Base: Minimal Fedora bootc image
FROM quay.io/fedora/fedora-bootc:42

# Layer 1: Enable RPM Fusion repositories
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    && dnf clean all

# Layer 2: Install Wayland/Graphics stack and base desktop dependencies
RUN dnf install -y \
    # Wayland core
    wayland-devel \
    wayland-protocols-devel \
    # Graphics libraries
    mesa-dri-drivers \
    mesa-libgbm \
    mesa-libEGL \
    libdrm \
    # Input and seat management
    libinput \
    libseat \
    libxkbcommon \
    # System services
    dbus \
    systemd \
    udev \
    # Audio/Video
    pipewire \
    pipewire-utils \
    wireplumber \
    # Font rendering
    pango \
    cairo \
    cairo-gobject \
    # Fonts
    dejavu-fonts \
    liberation-fonts \
    google-noto-sans-fonts \
    # Icons and themes
    adwaita-icon-theme \
    adwaita-cursor-theme \
    && dnf clean all

# Layer 3: Install GDM display manager
RUN dnf install -y \
    gdm \
    gnome-session \
    && dnf clean all

# Layer 4: Enable Niri COPR repository
RUN dnf copr enable -y yalter/niri

# Layer 5: Install Niri compositor and Wayland utilities
RUN dnf install -y \
    niri \
    # Screen locking
    swaylock \
    # Background management
    swaybg \
    swayidle \
    # XDG portals for screen sharing, file chooser, etc.
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    && dnf clean all

# Layer 6: Install essential desktop utilities referenced in config
RUN dnf install -y \
    # Terminal emulator
    kitty \
    # Application launcher
    rofi-wayland \
    # Status bar
    waybar \
    # Notification daemon
    mako \
    # Media control
    playerctl \
    # Brightness control
    brightnessctl \
    # Screenshot utilities
    grim \
    slurp \
    # Basic utilities
    polkit \
    NetworkManager \
    && dnf clean all

# Layer 7: Enable system services
RUN systemctl enable gdm.service && \
    systemctl set-default graphical.target

# Layer 8: Copy Niri configuration
COPY configs/niri/config.kdl /etc/niri/config.kdl

# Layer 9: Create GDM session file for Niri
RUN mkdir -p /usr/share/wayland-sessions && \
    printf '[Desktop Entry]\n\
Name=Niri\n\
Comment=Scrollable-tiling Wayland compositor\n\
Exec=niri-session\n\
Type=Application\n\
DesktopNames=niri\n' > /usr/share/wayland-sessions/niri.desktop && \
    chmod 644 /usr/share/wayland-sessions/niri.desktop

# Final cleanup
RUN dnf clean all && \
    rm -rf /var/cache/dnf
