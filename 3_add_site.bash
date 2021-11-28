# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-20-04

#step 2
read -p "Enter Site Name (example.com): " SITE;
read -p "Enter DB (no fancy characters): " DB;
read -p "Enter DB_PW: " DB_PW;
read -p "Enter PHP Version: " PHPV;
read -r -p "Are these correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "OK!"
else
    echo "exiting"
    exit
fi

# -- web files
cd /var/www/html/
#sudo apt install phpmyadmin -y
sudo rm -r temp
sudo mkdir temp
cd temp
sudo wget https://wordpress.org/latest.zip
sudo unzip -q latest.zip
cd ..
sudo cp -r temp/wordpress/ ./$SITE
sudo sh -c "echo '<?php phpinfo(); ?>' > /var/www/html/$SITE/info.php"
#sudo sh -c "echo '<?php phpinfo(); ?>' > /var/www/html/index.php"
cd "$SITE/"
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s#database_name_here#$DB#g" wp-config.php
sudo sed -i "s#username_here#$DB#g" wp-config.php
sudo sed -i "s#password_here#$DB_PW#g" wp-config.php

# -- hosts file
sudo sh -c "echo '127.0.0.1 $SITE' >> /etc/hosts"
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

# -- phpmyadmin
#sudo cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
#sudo cp /etc/phpmyadmin/apache.conf /etc/apache2/sites-available/phpmyadmin.conf
#sudo a2enconf phpmyadmin
#sudo service apache2 restart

# -- php versions
#sudo apt-get install software-properties-common -y
s#udo add-apt-repository ppa:ondrej/php
#sudo apt-get update -y
#sudo apt-get install php$PHPV php$PHPV-fpm php$PHPV-mysql libapache2-mod-php$PHPV libapache2-mod-fcgid -y
#sudo systemctl start php$PHPV-fpm
#sudo a2enmod actions fcgid alias proxy_fcgi
#sudo systemctl restart apache2 DELETE? FIXME!
#sudo a2ensite $DB
#sudo a2dissite 000-default.conf
#sudo systemctl restart apache2

# -- ssl
# https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04
#sudo a2enmod ssl
#sudo systemctl restart apache2
#sudo openssl req -x509 -nodes -days 9999 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
sudo cp ~/linux-dev/apache.conf "/etc/apache2/sites-available/$SITE.conf"
sudo sed -i "s#SITE#$SITE#g" /etc/apache2/sites-available/$SITE.conf
sudo sed -i "s#PHPV#$PHPV#g" /etc/apache2/sites-available/$SITE.conf
sudo a2ensite $SITE.conf
#sudo apache2ctl configtest
#sudo ufw allow "Apache Full"
sudo systemctl reload apache2

chromium "https://$SITE/wp-admin/install.php" & chromium http://localhost/phpmyadmin & chromium https://$SITE/info.php&



