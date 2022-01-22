echo "Before we begin:"
echo "Run this script from ~/linux-dev"
echo "Place the wordpress.zip file in this directory:"
echo "~/linux-dev/import/"
echo "Inside the wordpress.zip file should be a directory called 'wordpress', that is filled with the WP files."
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

sudo cp "import/wordpress.zip" "/var/www/html/"
cd /var/www/html/
if [ -d "temp" ] 
then
    rm -r temp
fi
mkdir temp
cd temp
unzip -q wordpress.zip
sudo rm -r "wordpress/wp-content"
sudo cp -r wordpress/* "$WEB_FILES/"
