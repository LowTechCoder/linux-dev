# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-20-04

read -p "Enter local site name without the '.loc': " L_SITE;
read -p "Enter DB PW: " DB_PW;
read -p "Enter PHP Version (7.4, 8.0): " PHPV;
read -r -p "Are these correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "OK!"
else
    echo "exiting"
    exit
fi

DB="$L_SITE"
L_SITE_LOC="$L_SITE.loc"
WEB_FILES="/var/www/html/$L_SITE_LOC"

# -- web files
cd /var/www/html/
if [ -d "temp" ] 
then
    sudo rm -r temp
fi
sudo mkdir temp
cd temp
sudo wget https://wordpress.org/latest.zip
sudo unzip -q latest.zip
cd ..
sudo cp -r temp/wordpress/ ./$L_SITE_LOC
sudo bash -c "echo '<?php phpinfo(); ?>' > /var/www/html/$L_SITE_LOC/info.php"
cd "$L_SITE_LOC/"
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s#database_name_here#$DB#g" wp-config.php
sudo sed -i "s#username_here#$DB#g" wp-config.php
sudo sed -i "s#password_here#$DB_PW#g" wp-config.php
sudo cp wp-config.php wp-config-add_site_backup.php

# -- hosts file
sudo bash -c "echo '127.0.0.1 $L_SITE_LOC' >> /etc/hosts"
sudo /bin/systemctl restart systemd-hostnamed

# -- sql
sudo mysql -u root -Bse "create database $DB;"
sudo mysql -u root -Bse "CREATE USER '$DB'@'localhost' IDENTIFIED BY '$DB_PW';"
#sudo mysql -u root -Bse "ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PW';"
sudo mysql -u root -Bse "GRANT ALL PRIVILEGES ON $DB.* TO '$DB'@'localhost';"
#phpmyadmin
#sudo mysql -u root -Bse "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost';"
#flush
sudo mysql -u root -Bse "flush privileges;"
sudo systemctl reload apache2

# -- ssl
# https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04
sudo cp ~/linux-dev/apache.conf "/etc/apache2/sites-available/$L_SITE_LOC.conf"
sudo sed -i "s#SITE#$L_SITE_LOC#g" /etc/apache2/sites-available/$L_SITE_LOC.conf
sudo sed -i "s#PHPV#$PHPV#g" /etc/apache2/sites-available/$L_SITE_LOC.conf
sudo a2ensite $L_SITE_LOC.conf
#sudo apache2ctl configtest
#sudo ufw allow "Apache Full"
sudo systemctl reload apache2

# do this again for some reason...
sudo chgrp -R www-data /var/www/html
sudo chown -R $USER /var/www/html/
sudo find /var/www/html -type d -exec chmod u+rwx {} +
sudo find /var/www/html -type f -exec chmod u+rw {} +

echo "https://$L_SITE_LOC/wp-admin/install.php"
echo "https://$L_SITE_LOC/info.php"
echo "The username for phpmyadmin is: phpmyadmin"
echo "http://localhost/phpmyadmin"
echo "/var/www/html/"
echo "/etc/apache2/sites-available/"
echo "/var/log/apache2/"
echo "Done!"
