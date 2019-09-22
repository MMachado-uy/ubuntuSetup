#!/bin/bash

function printInstallHeader()
{
    echo "*\n*\n*\n*\n";
    echo "Installing $1..."
    echo "*\n*\n*\n*\n";
    sleep 1;
}

function printheader()
{
    echo "*\n*\n*\n*\n";
    echo "$1..."
    echo "*\n*\n*\n*\n";
    sleep 1;

}

function installdeb()
{
    printInstallHeader $1
    wget -O $1 $2
    sudo dpkg -i $1
    rm $1
}

printheader 'Updating system'
sudo apt-get update
sudo apt-get -y upgrade

# @TODO: Change install flow to fetch from .bin repository
printheader 'Setting up folders and executables'
mkdir tmp
cp assets/.bin ~/
cd ~/.bin
find ~/.bin -type f -exec chmod +x {} \;
cd $OLDPWD

printheader 'Setting up .bashrc'
cp ~/.bashrc ~/.bashrc.old
cp assets/.bashrc ~/

printInstallHeader 'dependencies apt-transport-https, curl and wget'
sudo apt-get install -y apt-transport-https curl wget

printInstallHeader 'Sublime Text [Repos]'
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

printInstallHeader 'Visual Studio Code [Repos]'
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

printInstallHeader 'Git [Repos]'
sudo add-apt-repository -y ppa:git-core/ppa

printInstallHeader 'Virtualbox [Repos]'
echo "deb https://download.virtualbox.org/virtualbox/debian bionic contrib" | sudo tee /etc/apt/sources.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

printInstallHeader 'Gimp [Repos]'
sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp

printInstallHeader 'Peek [Repos]'
sudo add-apt-repository -y ppa:peek-developers/stable

printInstallHeader 'Shutter [Repos]'
sudo add-apt-repository -y ppa:linuxuprising/shutter

printInstallHeader 'Opera [Repos]'
wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=i386,amd64] https://deb.opera.com/opera-stable/ stable non-free"

printInstallHeader 'Spotify [Repos]'
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

printheader 'Updating system'
sudo apt-get update
sudo apt-get upgrade

printInstallHeader 'A bunch of stuff'
sudo apt-get install -y sublime-text code virtualbox-6.0 git vlc gimp gimp-gmic peek shutter opera-stable
sudo apt-get install  filezilla gparted spotify-client filelight meld fortunes cowsay

printInstallHeader 'NVM'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

printInstallHeader('NetBeans');
curl -o- http://espejito.fder.edu.uy/apache/netbeans/netbeans/11.1/Apache-NetBeans-11.1-bin-linux-x64.sh | bash

printInstallHeader 'Telegram (Binaries and .desktop)'
wget -O telegram.tar.xz https://telegram.org/dl/desktop/linux
tar xvxf telegram.tar.xz
mv Telegram ~/.bin/
find ~/.bin/Telegram -type f -exec chmod +x {} \;
cp assets/telegram.desktop ~/.local/share/applications/

printInstallHeader 'Postman'
~/.bin/install-postman
cp assets/postman.desktop  ~/.local/share/applications/

cd tmp
installdeb chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
installdeb steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
installdeb libgoocanvas-common.deb https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas-common_1.0.0-1_all.deb
installdeb libgoocanvas3.deb https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas3_1.0.0-1_amd64.deb
installdeb libgoocanvas-perl.deb https://launchpad.net/ubuntu/+archive/primary/+files/libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb; sudo apt-get -f install
installdeb skype.deb https://go.skype.com/skypeforlinux-64.deb
installdeb gnome-web-photo.deb http://mirrors.kernel.org/ubuntu/pool/universe/g/gnome-web-photo/gnome-web-photo_0.10.6-1_amd64.deb
installdeb slack.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.1-amd64.deb
cd $OLDPWD

printheader 'Some clean up'
sudo apt-get autoremove -y

printheader 'Setting up Sublime preferences'
cp assets/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/
git config --global alias.lg 'log --format="%C(auto)%h %Cgreen%s %Creset(%cN, %cr) %C(auto)%d" -10'
