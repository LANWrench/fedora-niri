# Base: Minimal Fedora bootc image
FROM quay.io/fedora/fedora-bootc:42

# Layer 1: Enable RPM Fusion repositories (for codecs and proprietary drivers)
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    && dnf clean all

# Layer 2: Enable Niri COPR repository
RUN dnf copr enable -y yalter/niri

# Layer 3: Install display manager and base desktop components
RUN dnf install -y \
    gdm \
    polkit \
    NetworkManager \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    && dnf clean all

# Layer 4: Install Niri and desktop utilities
# Note: niri automatically pulls in all Wayland/graphics dependencies
RUN dnf install -y \
    niri \
    kitty \
    rofi \
    waybar \
    mako \
    swaylock \
    playerctl \
    brightnessctl \
    grim \
    slurp \
    && dnf clean all

# Layer 5: Enable system services
RUN systemctl enable gdm.service && \
    systemctl set-default graphical.target

# Layer 6: Copy Niri configuration and create GDM session file
COPY configs/niri/config.kdl /etc/niri/config.kdl

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
