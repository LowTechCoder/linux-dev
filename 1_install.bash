#step1
sudo apt update
sudo apt upgrade
sudo apt install tasksel
sudo apt install unzip
sudo apt install spice-vdagent spice-webdavd
sudo install chromium-browser
sudo install neovim
sudo install git
git clone https://github.com/LowTechCoder/linux-nvim
mkdir .config/nvim/
cp linux-nvim/init.vim .config/nvim/
sudo apt install chromium-browser
read
sudo tasksel
#use tasksel to install server stuff
read
shutdown -r now
