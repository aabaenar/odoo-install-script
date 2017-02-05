# install-odoo-script

Install developement or production

# Basic usage

## Getting script

    sudo apt-get install git -y
    git clone https://github.com/rcastro-tyc/odoo-install-script

## Running script

    cd install-odoo-script

    sudo chmod +x odoo-install-script.sh
    sudo ./odoo-install-script

# Run script with parameters you need
(list of all parameters with default values can be found at odoo-installscript.sh)

    OE_USER="odoo"
    OE_HOME="/$OE_USER"
    OE_ADDONS="$OE_HOME/custom/addons"
    OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
    INSTALL_WKHTMLTOPDF="True"
    OE_PORT="8069"

Choose the Odoo version which you want to install. For example: 9.0, 8.0, 7.0 or saas-6. When using 'trunk' the master version will be installed.
IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 9.0

    OE_VERSION="9.0"

# Set to true if you have to install OCA custom addons
    INSTALL_CUSTOM="True"

# Set the superadmin password
    OE_SUPERADMIN="admin"

    OE_CONFIG="${OE_USER}-server"

## After installation

# Show settings (admin password, addons path)

    The Odoo server is up and running. Specifications:
    Port: 8069
    User service: odoo-server
    User PostgreSQL: odoo
    Code location: /odoo/
    Addons folder: /odoo/custom/addons/
    Start Odoo service: sudo service odoo-server start
    Stop Odoo service: sudo service odoo-server stop
    Restart Odoo service: sudo service odoo-server restart

    *log*
    tail -f -n 100 /var/log/odoo/odoo-server.log


# Contributors

* [@rcastro-tyc](https://github.com/rcastro-tyc)
