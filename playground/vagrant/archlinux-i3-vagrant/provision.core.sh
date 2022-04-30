#!/bin/sh
# this script must be executed as root user
username=$SUDO_USER
userhome=$(getent passwd $SUDO_USER | cut -d: -f6)
pacman --noconfirm -Syu
# remove guest utils provided by the box (they do not work in the GUI environment)
pacman --noconfirm -R virtualbox-guest-utils-nox
# feel free to add/remove packages as you need
pacman --noconfirm -S \
    base-devel net-tools vim wget git unzip openssh bash-completion \
    dialog alsa-utils pulseaudio \
    xorg-server xorg-xfontsel xorg-xrdb xorg-setxkbmap xorg-xinit xf86-video-intel xf86-input-synaptics xf86-input-libinput \
    i3-gaps slim dmenu \
    ttf-inconsolata terminus-font \
    xclip feh rxvt-unicode chromium \
    jdk9-openjdk \
    php php-mcrypt php-xsl xdebug php-intl php-gd composer \
    mariadb mariadb-clients libmariadbclient \
    apache php-apache \
    virtualbox-guest-utils

# add user to the audio group
usermod -a -G audio "${username}"

# configure php
sed -i -- 's/^memory_limit = 128M/memory_limit = -1/g' /etc/php/php.ini
sed -i -- 's/^display_errors = Off/display_errors = On/g' /etc/php/php.ini
sed -i -- 's/^;extension=bcmath.so/extension=bcmath.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=ftp.so/extension=ftp.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=gd.so/extension=gd.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=iconv.so/extension=iconv.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=intl.so/extension=intl.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=mcrypt.so/extension=mcrypt.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=pdo_mysql.so/extension=pdo_mysql.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=soap.so/extension=soap.so/g' /etc/php/php.ini
sed -i -- 's/^;extension=xsl.so/extension=xsl.so/g' /etc/php/php.ini
# enable xdebug
sed -i -- 's/^;//g' /etc/php/conf.d/xdebug.ini
echo 'xdebug.idekey=PHPSTORM' >>/etc/php/conf.d/xdebug.ini

# do not forget to run mysql_secure_installation

# configure apache to work with php
sed -i -- 's/^LoadModule mpm_event_module/#LoadModule mpm_event_module/g' /etc/httpd/conf/httpd.conf
sed -i -- 's/^#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/g' /etc/httpd/conf/httpd.conf
sed -i -- 's/^#LoadModule rewrite_module/LoadModule rewrite_module/g' /etc/httpd/conf/httpd.conf
sed -i -- 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
echo 'LoadModule php7_module modules/libphp7.so' >>/etc/httpd/conf/httpd.conf
echo 'Include conf/extra/php7_module.conf' >>/etc/httpd/conf/httpd.conf

# create folder for application instances
mkdir /srv/http/instances
chown "${username}:${username}" /srv/http/instances
# make sure that symlinks to home folder will work
chmod +x "${userhome}"

# enable display manager
systemctl enable slim.service
systemctl start slim.service

systemctl enable httpd.service
systemctl start httpd.service

mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl enable mysqld.service
systemctl start mysqld.service
