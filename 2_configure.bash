
#step 2
read -p "Enter DB: " DB;
read -p "Enter DB_USER: " DB_USER;
read -p "Enter DB_PW: " DB_PW;
echo "DB: $DB"
echo "DB_USER: $DB_USER"
echo "DB_PW: $DB_PW"
read -r -p "Are these correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "OK!"
else
    echo "exiting"
    exit
fi
cd /var/www/html/
sudo install phpmyadmin
#sudo nvim index.html 
#sudo nvim info.php
sudo mkdir temp
sudo cd temp
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo cd ..
sudo cp -r temp/wordpress/ ./$DB
sudo chown www-data:www-data "/var/www/html/$DB/" -R

cd "$DB/"
sudo cp wp-config-sample.php wp-config.php
#sudo nvim wp-config.php 

#Change all this:
#define('DB_NAME', 'database_name_here');
#define('DB_USER', 'username_here');
#define('DB_PASSWORD', 'password_here');
sed -i "s#database_name_here#$DB#g" wp-config.php
sed -i "s#username_here#$DB_USER#g" wp-config.php
sed -i "s#password_here#$DB_PW#g" wp-config.php

#sudo mysql -u root

#do mysql commands here
#   create database wordpress;
#   CREATE USER 'DB_USER'@'localhost' IDENTIFIED BY 'DB_PW';
# use this if you type in the wrong pw
#   ALTER USER 'DB_USER'@'localhost' IDENTIFIED BY 'DB_PW';
#   GRANT ALL PRIVILEGES ON wordpress.* TO 'DB_USER'@'localhost';
#   flush privileges;
#   exit;

sudo mysql -u root -Bse "create database $DB;"
sudo mysql -u root -Bse "CREATE USER 'DB_USER'@'localhost' IDENTIFIED BY 'DB_PW';"
sudo mysql -u root -Bse "GRANT ALL PRIVILEGES ON wordpress.* TO 'DB_USER'@'localhost';"
sudo mysql -u root -Bse "flush privileges;"

sudo systemctl reload apache2

sudo cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin
sudo service apache2 restart


chromium http://localhost/wordpress/wp-admin/install.php
chromium chrome-search:http://localhost/phpmyadmin
