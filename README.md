# MediaWikiAutoSetup
This script will handle downloading, unzipping, setting up MediaWiki, configuring the database, and installing necessary dependencies—everything a user needs to set up a MediaWiki instance without making any manual changes.
This script is intended to fully automate the setup and configuration of MediaWiki on a fresh Linux installation. It installs all necessary dependencies, sets up the database, configures Apache, and installs MediaWiki with no manual intervention.

# What it does 

Define Variables
The script begins by setting some variables: DB_NAME is the name of the MediaWiki database
DB_USER is the database username (root for simplicity)
DB_PASS is the password for the database user (set to root for full automation)
SERVER_IP is set to localhost, so MediaWiki is hosted on the local server
MEDIAWIKI_VERSION specifies the version of MediaWiki to download (1.42.3 in this case)
MEDIAWIKI_PATH is the path where MediaWiki files will be placed
MEDIAWIKI_URL is the link to the MediaWiki tar.gz file for the specified version

Check for Root Privileges
The script verifies if it’s being run as root. If not, it exits and asks the user to run it as root, since root privileges are required for installing packages and modifying system configurations.

Update and Install Dependencies
It updates the package list and upgrades any outdated packages. Then it installs all dependencies required for MediaWiki, including Apache, PHP, MariaDB, and necessary PHP modules.

Start and Secure MariaDB
Starts the MariaDB service and runs mariadb-secure-installation with pre-configured answers, setting a root password and securing the installation by disabling remote root login and removing anonymous users.

Database Setup
Configures MariaDB by creating a database named mediawiki, granting all privileges on it to the root user, and applying changes with FLUSH PRIVILEGES.

Download and Extract MediaWiki
Uses wget to download the specified MediaWiki version, saves it to a temporary location, extracts it, and moves it to the web server directory (MEDIAWIKI_PATH). Sets permissions to allow Apache to access these files.

Configure Apache for MediaWiki
Creates an Apache configuration file for MediaWiki, setting the document root to MEDIAWIKI_PATH and enabling URL rewrites. It then enables this configuration and restarts Apache to apply changes.

Run MediaWiki Command-Line Installer
Runs MediaWiki’s installer script, install.php, with parameters that specify the database name, user, password, server address, language, and other default settings. This allows MediaWiki to be set up automatically without any user input.

Set File Permissions
Ensures all files in the MediaWiki directory are accessible by setting permissions to 755.

Completion Message
The script prints a message indicating that the installation is complete and provides the URL for accessing the new MediaWiki instance.

# Installing

Clone the Repository
First, download the script from your GitHub repository. Open a terminal and run: git clone https://github.com/SleepTheGod/MediaWikiAutoSetup.git This will download the script to a local folder named MediaWikiAutoSetup.

Navigate to the Script Directory
Change into the directory where the script is located: cd MediaWikiAutoSetup

Make the Script Executable
Ensure that the script has the necessary permissions to run. Enter: chmod +x main.sh

Run the Script as Root
This script needs root privileges to install software and configure the system. Start it with: sudo ./main.sh The script will automatically handle the following tasks:

Installing Apache, PHP, and MariaDB, along with all necessary PHP modules
Configuring MariaDB, setting up the database, and creating a user for MediaWiki
Downloading and extracting MediaWiki files
Configuring Apache to serve MediaWiki from /var/www/html/wiki
Running MediaWiki’s installer to finalize the setup
Access Your MediaWiki Installation
Once the script completes, it will display a message with the URL for your MediaWiki instance. Open a web browser and go to: http://localhost/wiki
