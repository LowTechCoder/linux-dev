# switch php versions
# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-20-04
read -p "Enter DB: " DB;
read -p "Enter PHP: " PHPV;
echo "DB: $DB"
echo "PHP: $PHPV"
read -r -p "Are these correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "OK!"
else
    echo "exiting"
    exit
fi

sudo sh -c 'echo "
<VirtualHost *:80>
     ServerAdmin admin@$DB
     ServerName $DB
     DocumentRoot /var/www/$DB
     DirectoryIndex info.php

     <Directory /var/www/$DB>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
     </Directory>

    <FilesMatch \.php$>
        # From the Apache version 2.4.10 and above, use the SetHandler to run PHP as a fastCGI process server
         SetHandler \"proxy:unix:/run/php/php7.4-fpm.sock|fcgi://localhost\"
    </FilesMatch>

     ErrorLog ${APACHE_LOG_DIR}/$DB_error.log
     CustomLog ${APACHE_LOG_DIR}/$DB_access.log combined
</VirtualHost>" > /etc/apache2/sites-available/wp.conf'
read
sudo a2ensite $DB
read
sudo systemctl restart apache2
