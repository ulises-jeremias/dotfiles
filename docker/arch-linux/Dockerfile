FROM archlinux:latest

WORKDIR /home/demo

RUN pacman -Syyu --noconfirm \
    && pacman -S git vim sudo i3-gaps xorg-server xorg-xinit termite base-devel --noconfirm
    # echo "exec i3" >> ~/.xinitrc

RUN useradd demo -m \
    && passwd -d demo \
    && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && usermod -a -G wheel demo

USER demo

# Install yay
RUN git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noconfirm

WORKDIR /dotfiles

# Copy dofiles repository
COPY . .

# CMD [ "i3" ]