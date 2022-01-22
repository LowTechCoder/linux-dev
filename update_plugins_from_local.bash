echo "Before we begin:"
echo "Run this script from ~/linux-dev"
echo "Place the plugins.zip file in this directory:"
echo "~/linux-dev/import/"
echo "Inside the plugins.zip file should be a directory called 'plugins', that is filled with the plugins directories."
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

sudo cp "import/plugins.zip" "/var/www/html/"
cd /var/www/html/
if [ -d "temp" ] 
then
    rm -r temp
fi
mkdir temp
cd temp
unzip -q plugins.zip
sudo cp -r plugins/* "$WEB_FILES/"

