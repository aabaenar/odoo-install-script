#!/bin/bash
################################################################################
# Script for installing Odoo V8, V9, and also V10 on Ubuntu 14.04 LTS (could be used for other version too)
# Based on : Yenthe Van Ginneken https://github.com/Yenthe666/InstallScript and
#            Ivan Yelizariev https://github.com/it-projects-llc/install-odoo
#-------------------------------------------------------------------------------
# This script will install Odoo on your Ubuntu 14.04 or 16.04 server. It can install multiple Odoo instances
# in one Ubuntu because of the different xmlrpc_ports
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano odoo-install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x odoo-install.sh
# Execute the script to install Odoo:
# ./odoo-install
################################################################################

##fixed parameters
#odoo
OE_USER="odoo"
OE_HOME="/$OE_USER"
OE_ADDONS="$OE_HOME/custom/addons"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
#The default port where this Odoo instance will run under (provided you use the command -c in the terminal)
#Set to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"
#Set the default Odoo port (you still have to use -c /etc/odoo-server.conf for example to use this.)
OE_PORT="8069"
#Choose the Odoo version which you want to install. For example: 9.0, 8.0, 7.0 or saas-6. When using 'trunk' the master version will be installed.
#IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 9.0
OE_VERSION="9.0"
#Set to true if you have to install OCA custom addons
INSTALL_CUSTOM="True"
#set the superadmin password
OE_SUPERADMIN="admin"
OE_CONFIG="${OE_USER}-server"

##
###  WKHTMLTOPDF download links
## === Ubuntu Trusty x64 & x32 === (for other distributions please replace these two links,
## in order to have correct version of wkhtmltox installed, for a danger note refer to
## https://www.odoo.com/documentation/8.0/setup/install.html#deb ):
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install wget subversion git bzr bzrtools python-pip gdebi-core -y

echo -e "\n---- Install python packages ----"
sudo apt-get install python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil -y

echo -e "\n---- Install python libraries ----"
sudo -H pip install gdata psycogreen ofxparse

echo -e "\n--- Install other required packages"
sudo apt-get install node-clean-css -y
sudo apt-get install node-less -y
sudo apt-get install python-gevent -y

echo -e "\n---- Installing Node & Less specific libraries ----"
sudo apt-get install nodejs npm -y
sudo npm install -g less
sudo npm install -g less-plugin-clean-css

echo -e "\n--- Create symlink for node"
sudo ln -s /usr/bin/nodejs /usr/bin/node

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 9 ----"
  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url
  sudo gdebi --n `basename $_url`
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
fi

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install ODOO and OCA custom addons
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/OCB $OE_HOME_EXT/

echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir -p $OE_ADDONS"

if [ $INSTALL_CUSTOM = "True" ]; then
  echo -e "\n==== Installing ODOO custom addons ===="
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/website $OE_ADDONS/oca/website
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/partner-contact $OE_ADDONS/oca/partner-contact
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/web $OE_ADDONS/oca/web
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/server-tools $OE_ADDONS/oca/server-tools
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/account-financial-tools $OE_ADDONS/oca/account-financial-tools
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/stock-logistics-workflow $OE_ADDONS/oca/stock-logistics-workflow
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/stock-logistics-warehouse $OE_ADDONS/oca/stock-logistics-warehouse
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/purchase-workflow $OE_ADDONS/oca/purchase-workflow
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/account-invoicing $OE_ADDONS/oca/account-invoicing
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/social $OE_ADDONS/oca/social
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/sale-workflow $OE_ADDONS/oca/sale-workflow
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/event $OE_ADDONS/oca/event
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/e-commerce $OE_ADDONS/oca/e-commerce
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/account-invoice-reporting $OE_ADDONS/oca/account-invoice-reporting
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/account-financial-reporting $OE_ADDONS/oca/account-financial-reporting
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/hr $OE_ADDONS/oca/hr
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/project $OE_ADDONS/oca/project
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/account-payment $OE_ADDONS/oca/account-payment
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/runbot-addons $OE_ADDONS/oca/runbot-addons
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/product-attribute $OE_ADDONS/oca/product-attribute
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/product-variant $OE_ADDONS/oca/product-variant
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/crm $OE_ADDONS/oca/crm
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/contract $OE_ADDONS/oca/contract
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/account-analytic $OE_ADDONS/oca/account-analytic
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/OCA/stock-logistics-transport $OE_ADDONS/oca/stock-logistics-transport
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/it-projects-llc/mail-addons $OE_ADDONS/it-projects-llc/mail-addons
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/it-projects-llc/website-addons $OE_ADDONS/it-projects-llc/website-addons
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/it-projects-llc/access-addons $OE_ADDONS/it-projects-llc/access-addons
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/it-projects-llc/pos-addons $OE_ADDONS/it-projects-llc/pos-addons
  sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/Vauxoo/addons-vauxoo $OE_ADDONS/vauxoo/addons-vauxoo
else
  echo "OCA custom addons isn't installed due to the choice of the user!"
fi

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Create server config file"
sudo cp $OE_HOME_EXT/debian/openerp-server.conf /etc/${OE_CONFIG}.conf
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Change server config file"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/${OE_CONFIG}.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/${OE_CONFIG}.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "echo 'addons_path=$OE_HOME_EXT/addons,$OE_HOME/custom/addons' >> /etc/${OE_CONFIG}.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
cat <<EOF > ~/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Enterprise Business Applications
# Description: ODOO Business Applications
### END INIT INFO
PATH=/bin:/sbin:/usr/bin
DAEMON=$OE_HOME_EXT/openerp-server
NAME=$OE_CONFIG
DESC=$OE_CONFIG
# Specify the user name (Default: odoo).
USER=$OE_USER
# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="/etc/${OE_CONFIG}.conf"
# pidfile
PIDFILE=/var/run/\${NAME}.pid
# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"
[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0
checkpid() {
[ -f \$PIDFILE ] || return 1
pid=\`cat \$PIDFILE\`
[ -d /proc/\$pid ] && return 0
return 1
}
case "\${1}" in
start)
echo -n "Starting \${DESC}: "
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
stop)
echo -n "Stopping \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
echo "\${NAME}."
;;
restart|force-reload)
echo -n "Restarting \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
sleep 1
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
*)
N=/etc/init.d/\$NAME
echo "Usage: \$NAME {start|stop|restart|force-reload}" >&2
exit 1
;;
esac
exit 0
EOF

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "* Change default xmlrpc port"
sudo su root -c "echo 'xmlrpc_port = $OE_PORT' >> /etc/${OE_CONFIG}.conf"

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults

echo -e "* Starting Odoo Service"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Addons folder: $OE_USER/$OE_CONFIG/addons/"
echo "Start Odoo service: sudo service $OE_CONFIG start"
echo "Stop Odoo service: sudo service $OE_CONFIG stop"
echo "Restart Odoo service: sudo service $OE_CONFIG restart"
echo "-----------------------------------------------------------"
