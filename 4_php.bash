# switch php versions
# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-20-04

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
         SetHandler "proxy:unix:/run/php/php$PHP-fpm.sock|fcgi://localhost"
    </FilesMatch>

     ErrorLog ${APACHE_LOG_DIR}/$DB_error.log
     CustomLog ${APACHE_LOG_DIR}/$DB_access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$DB.conf'
sudo a2ensite $DB
sudo systemctl restart apache2
