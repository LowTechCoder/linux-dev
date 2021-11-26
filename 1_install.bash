#step1
sudo apt update
sudo apt upgrade
sudo apt install tasksel
sudo apt install unzip
sudo apt install spice-vdagent spice-webdavd
sudo install chromium
sudo install neovim
sudo install git
sudo install phpmyadmin
git clone https://github.com/LowTechCoder/linux-nvim
mkdir .config/nvim/
cp linux-nvim/init.vim .config/nvim/
sudo apt install chromium-browser
sudo tasksel
#use tasksel to install server stuff
shutdown -r now
