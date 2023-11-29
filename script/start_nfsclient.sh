#!/bin/bash

# Muestra todos los comandos que se han ejeutado.
set -ex

# Actualización de repositorios
apt update

# Incluimos las variables del archivo .env.
source .env

# Instalacion de paquetes necesarios en el cliente nfs.
apt install nfs-common -y

# Montaje de la carpeta estableciendo la ip del servidor NFS.
mount $IP_NFS:/var/www/html /var/www/html

# Para que la unidad se monte automaticamente y con los >> me añade al final en el /etc/fstab para que al reiniciar se monte sola, tras el reinicio.
echo "$IP_NFS:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab