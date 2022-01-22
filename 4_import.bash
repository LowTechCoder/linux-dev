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
DB="$L_SITE"
L_SITE_LOC="$L_SITE.loc"
WEB_FILES="/var/www/html/$L_SITE_LOC"
PREFIX=$(cat "import/$L_SITE_LOC/wp-config.php" | grep "table_prefix" | sed "s#'##g" | sed 's# ##g' | sed 's#^.*=##g' | sed 's#_.*##g')
echo "Using prefix: $PREFIX"
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


#copy local config to backup
cp "$WEB_FILES/wp-config.php" "$WEB_FILES/wp-config-backup.php"
#copy remote files into local
cp -r import/$L_SITE_LOC/* "$WEB_FILES/"
#overwrite remote config
cp "$WEB_FILES/wp-config-backup.php" "$WEB_FILES/wp-config.php"
LINE_NUM=$(grep -n "table_prefix" "$WEB_FILES/wp-config.php" | awk -F  ":" '{print $1}')
sed -i "$LINE_NUM"'s#wp#'"$PREFIX"'#g' "$WEB_FILES/wp-config.php"

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

#deleting the wps-hide-login, if there is one.
rm -r "$WEB_FILES/wp-content/plugins/wps-hide-login/"

# change all files to 664
sudo find "/var/www" -type f -exec chmod 664 {} + 

# change all folders to 775
sudo find "/var/www" -type d -exec chmod 775 {} +

# add user to www-data
sudo adduser $USER www-data

# change user:group
sudo chown -R www-data:www-data '/var/www'

sudo chmod -R g+rwX '/var/www'

echo "All done.  You may need to logout and back in, for your user to be added to the www-data group, but probably not."
echo
echo "Useful links and paths:"
echo
echo "https://$L_SITE_LOC/info.php"
echo "https://$L_SITE_LOC/wp-login.php"
echo "The username for phpmyadmin is: phpmyadmin"
echo "http://localhost/phpmyadmin"
echo "/var/www/html/"
echo "/etc/apache2/sites-available/"
echo "/var/log/apache2/"
echo "Done!"
