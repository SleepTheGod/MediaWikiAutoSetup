#!/bin/bash

# Variables
DB_NAME="mediawiki"
DB_USER="root"
DB_PASS="root"
SERVER_IP="localhost"
MEDIAWIKI_VERSION="1.42.3"
MEDIAWIKI_PATH="/var/www/html/wiki"
MEDIAWIKI_URL="https://releases.wikimedia.org/mediawiki/1.42/mediawiki-core-$MEDIAWIKI_VERSION.tar.gz"

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Update packages and install all necessary dependencies
echo "Updating packages and installing all required software..."
apt update && apt upgrade -y
apt install -y apache2 php mariadb-server php-mysql php-intl php-mbstring php-xml php-json php-curl php-gd php-cli php-apcu wget unzip build-essential || { echo "Dependency installation failed."; exit 1; }

# Start and secure MariaDB
echo "Starting MariaDB and configuring default database..."
systemctl start mariadb || { echo "Failed to start MariaDB."; exit 1; }
mariadb-secure-installation <<EOF

y
$DB_PASS
$DB_PASS
y
y
y
y
EOF

# Set up MariaDB database and user for MediaWiki
mariadb -u root -p"$DB_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
FLUSH PRIVILEGES;
EOF

# Download and extract MediaWiki
echo "Downloading MediaWiki version $MEDIAWIKI_VERSION..."
wget -q "$MEDIAWIKI_URL" -O /tmp/mediawiki.tar.gz || { echo "Failed to download MediaWiki."; exit 1; }
tar -xzf /tmp/mediawiki.tar.gz -C /tmp || { echo "Failed to extract MediaWiki."; exit 1; }
mv /tmp/mediawiki-* "$MEDIAWIKI_PATH"
chown -R www-data:www-data "$MEDIAWIKI_PATH"

# Configure Apache for MediaWiki
echo "Configuring Apache for MediaWiki..."
cat <<EOL >/etc/apache2/sites-available/mediawiki.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $MEDIAWIKI_PATH

    Alias /wiki $MEDIAWIKI_PATH

    <Directory "$MEDIAWIKI_PATH">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/mediawiki_error.log
    CustomLog \${APACHE_LOG_DIR}/mediawiki_access.log combined
</VirtualHost>
EOL

# Enable Apache mods and restart
a2enmod rewrite
a2ensite mediawiki.conf
systemctl restart apache2 || { echo "Failed to restart Apache."; exit 1; }

# Run MediaWiki installer in command-line mode with defaults
echo "Running MediaWiki installer..."
php "$MEDIAWIKI_PATH/maintenance/install.php" \
    --dbname "$DB_NAME" \
    --dbuser "$DB_USER" \
    --dbpass "$DB_PASS" \
    --dbserver "localhost" \
    --installdbuser "$DB_USER" \
    --installdbpass "$DB_PASS" \
    --server "http://$SERVER_IP" \
    --scriptpath "/wiki" \
    --lang en \
    --pass "$DB_PASS" \
    "MyWiki" \
    "Admin" || { echo "MediaWiki installation failed."; exit 1; }

# Set appropriate permissions
chmod -R 755 "$MEDIAWIKI_PATH"

echo "MediaWiki installation is complete!"
echo "Access your MediaWiki at http://$SERVER_IP/wiki"
