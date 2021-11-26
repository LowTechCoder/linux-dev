###ssl
# https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04
sudo ufw allow "Apache Full"
sudo a2enmod ssl
sudo systemctl restart apache2
sudo openssl req -x509 -nodes -days 9999 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
#sudo nvim /etc/apache2/sites-available/localhost.conf
sudo sh -c 'echo "
<VirtualHost *:443>
   ServerName localhost
   DocumentRoot /var/www/html

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>" > /etc/apache2/sites-available/localhost.conf'
sudo a2ensite localhost.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
