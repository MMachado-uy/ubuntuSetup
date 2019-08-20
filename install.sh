#!/bin/bash

function installdeb()
{
    wget -O $1 $2
    sudo dpkg -i $1
    rm $1
}

sudo apt-get update
sudo apt-get -y upgrade

mkdir tmp
cp assets/.bin ~/
cd ~/.bin
find ~/.bin -type f -exec chmod +x {} \;
cd $OLDPWD

cp ~/.bashrc ~/.bashrc.old
cp assets/.bashrc ~/

sudo apt-get install -y apt-transport-https curl wget

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo add-apt-repository -y ppa:git-core/ppa
echo "deb https://download.virtualbox.org/virtualbox/debian bionic contrib" | sudo tee /etc/apt/sources.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp
sudo add-apt-repository -y ppa:peek-developers/stable
sudo add-apt-repository -y ppa:linuxuprising/shutter
sudo add-apt-repository -y 'deb https://deb.opera.com/opera-stable/ stable non-free'
wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y sublime-text code git virtualbox-6.0 vlc gimp gimp-plugin-registry gimp-gmic peek shutter gnome-web-photo opera-stable netbeans
sudo apt-get install  filezilla gparted spotify-client arduino filelight slack meld fortunes cowsay

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

wget -O telegram.tar.xz https://telegram.org/dl/desktop/linux
tar xvxf telegram.tar.xz
mv Telegram ~/.bin/
find ~/.bin/Telegram -type f -exec chmod +x {} \;
cp assets/telegram.desktop ~/.local/share/applications/

~/.bin/install-postman
cp assets/postman.desktop  ~/.local/share/applications/

cd tmp
installdeb chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
installdeb steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
installdeb libgoocanvas-common.deb https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas-common_1.0.0-1_all.deb
installdeb libgoocanvas3.deb https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas3_1.0.0-1_amd64.deb
installdeb libgoocanvas-perl.deb https://launchpad.net/ubuntu/+archive/primary/+files/libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb
installdeb skype.deb https://go.skype.com/skypeforlinux-64.deb
cd $OLDPWD

sudo apt-get autoremove -y

cp assets/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/
git config --global alias.lg 'log --format="%C(auto)%h %Cgreen%s %Creset(%cN, %cr) %C(auto)%d" -10'
