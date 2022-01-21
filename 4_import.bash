echo "Before we begin:"
echo "Run this script from ~/linux-dev"
echo "Make sure the site files are in a folder, and the parent directory is named the same as the local dev site directory (example.loc) and located in this directory."
echo "~/linux-dev/import/"
echo "Make sure the sql file is named the same as the local dev site DB and located in this directory."
echo "~/linux-dev/import/"
echo "example:"
echo "- import"
echo "---- example.loc"
echo "---- example"
echo "Local site list:"
ls "/var/www/html/"
echo "Hit ENTER to continue..."
read

read -p "Enter Remote Site Name (website.com): " R_SITE;
read -p "Enter Local Dev Site Name without the '.loc' (example): " L_SITE;
#read -p "Enter DB (example): " DB;
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
WEB_FILES="/var/www/html/$L_SITE.loc"
#copy local config to backup
sudo cp "$WEB_FILES/wp-config.php" "$WEB_FILES/wp-config-backup.php"
#copy remote files into local
sudo cp -r import/$L_SITE.loc/* "$WEB_FILES/"
#overwrite remote config
sudo cp "$WEB_FILES/wp-config-backup.php" "$WEB_FILES/wp-config.php"
LINE_NUM=$(grep -n "table_prefix" "$WEB_FILES/wp-config.php" | awk -F  ":" '{print $1}')
sudo sed -i "$LINE_NUM"'s#wp#'"$PREFIX"'#g' "$WEB_FILES/wp-config.php"


#echo "db.sql 'test.com' 'test.affaridev.com'"
cd import
db_input="$L_SITE"
domain_input="$R_SITE"
domain_output="$L_SITE.loc"
db_output="$db_input.output.sql"
sed "s#https://www.$domain_input#https://$domain_output#g" "$db_input.sql" > "$db_output"
sed -i "s#http://www.$domain_input#https://$domain_output#g" "$db_output"
sed -i "s#https://$domain_input#https://$domain_output#g" "$db_output"
sed -i "s#http://$domain_input#https://$domain_output#g" "$db_output"
sed -i "s#$domain_input#$domain_output#g" "$db_output"

PROJECT="$L_SITE"
sed -i 's/\sDEFINER=`[^`]*`@`[^`]*`//g' "$db_output"
sudo mysql -u root -p -e "drop database $PROJECT"
sudo mysql -u root -p -e "create database $PROJECT"
sudo mysql -u root -p $PROJECT < "$db_output"

echo "output file: $db_output"
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

echo "copy/paste these into chrome"
echo "https://$L_SITE.loc/info.php"
echo "https://$L_SITE.loc/wp-login.php"
echo "Done!!"


