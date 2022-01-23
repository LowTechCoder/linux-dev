echo "Before we begin:"
echo "Run this script from ~/linux-dev"
echo "Place the wordpress.zip file in this directory:"
echo "~/linux-dev/import/"
echo "Local site list:"
ls "/var/www/html/"
echo "Hit ENTER to continue..."
read
read -p "Enter local site name without the '.loc': " L_SITE;
DB="$L_SITE"
L_SITE_LOC="$L_SITE.loc"
WEB_FILES="/var/www/html/$L_SITE_LOC"
read -r -p "Are these correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "OK!"
else
    echo "exiting"
    exit
fi

cd /var/www/html/
if [ -d "temp" ] 
then
    sudo rm -r temp
fi
mkdir temp
cd temp
sudo cp "$HOME/linux-dev/import/wordpress.zip" "/var/www/html/temp/"
sudo unzip -q wordpress.zip
sudo rm -r wordpress.zip
if [ -d "wordpress" ] 
then
    sudo rm -r "wordpress/wp-content"
    sudo cp -r wordpress/* "$WEB_FILES/"
else
    sudo rm -r "wp-content"
    sudo cp -r * "$WEB_FILES/"
fi

# change all files to 664
sudo find "/var/www" -type f -exec chmod 664 {} + 
# change all folders to 775
sudo find "/var/www" -type d -exec chmod 775 {} +
# add user to www-data
sudo adduser $USER www-data
# change user:group
sudo chown -R www-data:www-data '/var/www'
# make writable to all in group
sudo chmod -R g+rwX '/var/www'
echo "All done.  You may need to logout and back in, for your user to be added to the www-data group, but probably not."
