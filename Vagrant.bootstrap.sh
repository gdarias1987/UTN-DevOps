#!/bin/bash
echo "------- Grupo 2 -------"

### Aprovisionamiento de software ###

# Actualizo los paquetes de la máquina virtual
sudo apt-get update

# Instalo un servidor web y Git
sudo apt-get install -y apache2 git

### Configuración del entorno ###

## Genero una partición swap para prevenir errores de falta de memoria
SWAP_PATH="/swapdir/swapfile"

if [ ! -f "$SWAP_PATH" ]; then
    sudo mkdir -p /swapdir
    sudo dd if=/dev/zero of=$SWAP_PATH bs=1024 count=2000000
    sudo chmod 0600 $SWAP_PATH
    sudo mkswap -f $SWAP_PATH
    sudo swapon $SWAP_PATH
    echo "$SWAP_PATH none swap sw 0 0" | sudo tee -a /etc/fstab
    sudo sysctl vm.swappiness=10
    echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf
fi

## Configuración del servidor web
# Copio el archivo de configuración del repositorio en la configuración del servidor web
if [ -f "/tmp/devops.site.conf" ]; then
    echo "Copiando el archivo de configuración de Apache"
    sudo mv /tmp/devops.site.conf /etc/apache2/sites-available/
    sudo a2ensite devops.site.conf
    sudo a2dissite 000-default.conf
    sudo systemctl reload apache2
fi

## Configuración de la aplicación
# Ruta raíz del servidor web
APACHE_ROOT="/var/www"
# Ruta de la aplicación
APP_PATH="$APACHE_ROOT/moldJS"

if [ ! -d "$APACHE_ROOT" ]; then
    sudo mkdir -p $APACHE_ROOT
    sudo chown -R vagrant:vagrant $APACHE_ROOT
fi

# Descargar la aplicación si no existe
if [ ! -d "$APP_PATH" ]; then
    echo "Clonando el repositorio moldJS en $APP_PATH"
    cd $APACHE_ROOT
    sudo -u vagrant git clone https://github.com/gdarias1987/moldJS.git
    cd $APP_PATH
    sudo -u vagrant git checkout master
else
    echo "Repositorio ya existe en $APP_PATH, actualizando..."
    cd $APP_PATH
    sudo -u vagrant git pull origin master
fi

# Permisos adecuados
sudo chown -R vagrant:vagrant $APACHE_ROOT
sudo chmod -R 755 $APACHE_ROOT

echo "Configuración finalizada."
