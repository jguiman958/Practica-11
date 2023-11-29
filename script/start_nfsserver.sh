#!/bin/bash

# Muestra todos los comandos que se han ejeutado.

set -ex

# Actualización de repositorios
 sudo apt update

# Incluimos las variables del archivo .env.
source .env

# Instalamos nfsserver.
apt install nfs-kernel-server -y

# Creamos el directorio que queremos compartir.
mkdir -p /var/www/html

# Damos permisos especiales.
chown nobody:nogroup /var/www/html

# Editamos el archivo /etc/exports
cp ../exports/exports /etc/exports

# Cambiamos el contenido del export para incorporar la ip privada del servidor nfs. 
sed -i "s#NFS_FRONTEND_NETWORK#$NFS_FRONTEND_NETWORK#" /etc/exports

# Reiniciamos el servicio de nfs. 
systemctl restart nfs-kernel-server