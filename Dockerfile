# Base: Minimal Fedora bootc image
FROM quay.io/fedora/fedora-bootc:42

# Layer 1: Enable RPM Fusion repositories (for codecs and proprietary drivers)
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    && dnf clean all

# Layer 2: Enable Niri COPR repository
RUN dnf install -y 'dnf5-command(copr)' && \
    dnf copr enable -y yalter/niri && \
    dnf clean all

# Layer 3: Install display manager and base desktop components
RUN dnf install -y \
    gdm \
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

# Layer 5: Configure systemd for graphical boot
# Create systemd preset to enable GDM
RUN mkdir -p /usr/lib/systemd/system-preset && \
    echo "enable gdm.service" > /usr/lib/systemd/system-preset/90-gdm.preset && \
    ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

# Layer 6: Copy Niri configuration and create GDM session file
COPY configs/niri/config.kdl /etc/niri/config.kdl

RUN mkdir -p /usr/share/wayland-sessions

COPY --chmod=644 system/usr_share_wayland-sessions_niri.desktop /usr/share/wayland-sessions/niri.desktop

# Layer 7: Trigger SELinux relabeling on first boot
# This ensures all files have correct SELinux contexts after package installation
RUN touch /.autorelabel

# Final cleanup
RUN dnf clean all && \
    rm -rf /var/cache/dnf/* && \
    rm -rf /tmp/* /var/tmp/*
