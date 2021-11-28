# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-20-04

echo "check the 'apache2' boxy by hitting 'space' then 'enter' to choose 'ok' button"
echo "press 'enter' to continue"
read
sudo apt install phpmyadmin -y

#phpmyadmin
sudo mysql -u root -Bse "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost';"
#flush
sudo mysql -u root -Bse "flush privileges;"

#sudo cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
#sudo cp /etc/phpmyadmin/apache.conf /etc/apache2/sites-available/phpmyadmin.conf
sudo a2enconf phpmyadmin
sudo service apache2 restart


sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update -y
PHPV=7.4
sudo apt-get install php$PHPV php$PHPV-fpm php$PHPV-mysql libapache2-mod-php$PHPV libapache2-mod-fcgid -y
sudo systemctl start php$PHPV-fpm
sudo a2enmod actions fcgid alias proxy_fcgi
sudo systemctl restart apache2

#disable default apache conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04
sudo a2enmod ssl
sudo systemctl restart apache2
echo "Doing ssl.  Hit 'enter' to skip most (can skip first 5)"
echo "Type in 'localhost' for 'Common Name'"
echo "Press ENTER to continue"
read
sudo openssl req -x509 -nodes -days 9999 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

#test your conf
#sudo apache2ctl configtest
sudo ufw allow "Apache Full"
sudo systemctl reload apache2

echo "DONE!!"
chromium http://localhost/phpmyadmin



