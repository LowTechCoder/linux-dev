# change user:group
sudo chown www-data:www-data "/var/www/html" -R

# change all files to 664
sudo find "/var/www/html" -type f -exec chmod 664 {} + 

# change all folders to 775
sudo find "/var/www/html" -type d -exec chmod 775 {} +
