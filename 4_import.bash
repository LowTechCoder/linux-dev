echo "Before we begin:"
echo "Run this script from ~/linux-dev"
echo "Make sure the site files are in a folder, and the parent directory is named the same as the local dev site directory (example.loc) and located in this directory."
echo "~/linux-dev/import/"
echo "Make sure the sql file is named the same as the local dev site DB and located in this directory."
echo "~/linux-dev/import/"
echo "example:"
echo "- import"
echo "---- example.loc"
echo "---- example.sql"
echo "Local site list:"
ls "/var/www/html/"
echo "Hit ENTER to continue..."
read

read -p "Enter remote site name (example.com): " R_SITE;
read -p "Enter local site name without the '.loc': " L_SITE;
#read -p "Enter DB PW: " DB_PW; #do we need this?
read -r -p "Are these correct? [y/N] " response
read -p "Enter wp-config.php prefix without the trailing underscore. (wp): " PREFIX;
read -r -p "Are these correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "OK!"
else
    echo "exiting"
    exit
fi
echo "Starting Apache..."
sudo systemctl start apache2.service

DB="$L_SITE"
L_SITE_LOC="$L_SITE.loc"
WEB_FILES="/var/www/html/$L_SITE_LOC"

#copy local config to backup
sudo cp "$WEB_FILES/wp-config.php" "$WEB_FILES/wp-config-backup.php"
#copy remote files into local
sudo cp -r import/$L_SITE_LOC/* "$WEB_FILES/"
#overwrite remote config
sudo cp "$WEB_FILES/wp-config-backup.php" "$WEB_FILES/wp-config.php"
LINE_NUM=$(grep -n "table_prefix" "$WEB_FILES/wp-config.php" | awk -F  ":" '{print $1}')
sudo sed -i "$LINE_NUM"'s#wp#'"$PREFIX"'#g' "$WEB_FILES/wp-config.php"

cd import
DB_OUTPUT="$DB.output.sql"
sed "s#https://www.$R_SITE#https://$L_SITE_LOC#g" "$DB.sql" > "$DB_OUTPUT"
sed -i "s#http://www.$R_SITE#https://$L_SITE_LOC#g" "$DB_OUTPUT"
sed -i "s#https://$R_SITE#https://$L_SITE_LOC#g" "$DB_OUTPUT"
sed -i "s#http://$R_SITE#https://$L_SITE_LOC#g" "$DB_OUTPUT"
sed -i "s#$R_SITE#$L_SITE_LOC#g" "$DB_OUTPUT"

PROJECT="$L_SITE"
sed -i 's/\sDEFINER=`[^`]*`@`[^`]*`//g' "$DB_OUTPUT"
sudo mysql -u root -p -e "drop database $DB"
sudo mysql -u root -p -e "create database $DB"
sudo mysql -u root -p $DB < "$DB_OUTPUT"

echo "DB output file: $DB_OUTPUT"
cd ..

# do this again for some reason...
sudo chgrp -R www-data /var/www/html
sudo chown -R $USER /var/www/html/
sudo find /var/www/html -type d -exec chmod u+rwx {} +
sudo find /var/www/html -type f -exec chmod u+rw {} +

sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

#deleting the wps-hide-login, if there is one.
sudo rm -r "$WEB_FILES/wp-content/plugins/wps-hide-login/"

echo "https://$L_SITE_LOC/info.php"
echo "https://$L_SITE_LOC/wp-login.php"
echo "The username for phpmyadmin is: phpmyadmin"
echo "http://localhost/phpmyadmin"
echo "/var/www/html/"
echo "/etc/apache2/sites-available/"
echo "/var/log/apache2/"
echo "Done!"
