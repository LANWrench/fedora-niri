FROM quay.io/fedora/fedora-sway-atomic:42

# Enable RPM Fusion Free and Nonfree
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    && dnf clean all

# Now you can install packages from RPM Fusion
RUN dnf remove -y sway && \
    dnf autoremove -y && \
    dnf install -y niri && \
    dnf clean all