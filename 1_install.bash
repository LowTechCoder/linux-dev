#step1
sudo apt update
sudo apt upgrade -y
sudo apt install tasksel -y
sudo apt install unzip -y
sudo apt install spice-vdagent spice-webdavd -y
sudo apt install chromium-browser -y
sudo apt install neovim -y
sudo apt install git -y
git clone https://github.com/LowTechCoder/linux-nvim
mkdir .config/nvim/
cp linux-nvim/init.vim .config/nvim/
sudo apt install chromium-browser
echo "Select LAMP Server and what ever else"
echo "Press ENTER key to continue to tasksel"
read
sudo tasksel
sudo chown www-data:www-data "/var/www/html" -R
sudo chmod -R 755 /var/www/html
#use tasksel to install server stuff
echo "Press ENTER key to restart"
read
shutdown -r now
