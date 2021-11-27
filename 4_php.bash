# switch php versions
# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-20-04
read -p "Enter DB: " DB;
read -p "Enter PHP Version: " PHPV;
read -r -p "Are these correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "OK!"
else
    echo "exiting"
    exit
fi

sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update -y
sudo apt-get install php$PHPV php$PHPV-fpm php$PHPV-mysql libapache2-mod-php$PHPV libapache2-mod-fcgid -y
sudo systemctl start php$PHPV-fpm
sudo systemctl start php$PHPV-fpm
sudo a2enmod actions fcgid alias proxy_fcgi
sudo systemctl restart apache2


sudo sh -c 'echo "
<VirtualHost *:80>
     ServerAdmin admin@DB
     ServerName DB
     DocumentRoot /var/www/html/
     DirectoryIndex index.php

     <Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
     </Directory>

    <FilesMatch \.php$>
        # From the Apache version 2.4.10 and above, use the SetHandler to run PHP as a fastCGI process server
         SetHandler \"proxy:unix:/run/php/phpPHPV-fpm.sock|fcgi://localhost\"
    </FilesMatch>

     ErrorLog ${APACHE_LOG_DIR}/DB_error.log
     CustomLog ${APACHE_LOG_DIR}/DB_access.log combined
</VirtualHost>" > /etc/apache2/sites-available/DB.conf'
sudo sed -i "s#DB#$DB#g" /etc/apache2/sites-available/DB.conf
sudo sed -i "s#PHPV#$PHPV#g" /etc/apache2/sites-available/DB.conf
sudo mv /etc/apache2/sites-available/DB.conf "/etc/apache2/sites-available/$DB.conf"
sudo a2ensite $DB
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
