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
