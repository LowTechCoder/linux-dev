#step1
sudo apt update
sudo apt upgrade -y
sudo apt install tasksel -y
sudo apt install unzip -y
sudo apt install spice-vdagent spice-webdavd -y
sudo apt install chromium-browser -y
sudo apt install firefox -y
sudo apt install neovim -y
sudo apt install git -y
git clone https://github.com/LowTechCoder/linux-nvim
mkdir -p ~/.config
mkdir -p ~/.config/nvim/
cp linux-nvim/init.vim ~/.config/nvim/
sudo apt install chromium-browser
echo "Select LAMP Server and what ever else"
echo "Press ENTER key to continue to tasksel"
read
sudo tasksel
#use tasksel to install server stuff
# change all files to 664
sudo find "/var/www" -type f -exec chmod 664 {} + 

# change all folders to 775
sudo find "/var/www" -type d -exec chmod 775 {} +

# add user to www-data
sudo adduser $USER www-data

# change user:group
sudo chown -R www-data:www-data '/var/www'

# make writable to all in group
sudo chmod -R g+rwX '/var/www'
echo "Press ENTER key to restart"
read
shutdown -r now
