#!/bin/bash

# Muestra todos los comandos que se han ejeutado.
set -ex

# Actualización de repositorios
sudo apt update

# Incluimos las variables del archivo .env.
source .env

# Instalacion de paquetes necesarios en el cliente nfs.
apt install nfs-common -y

# Montaje de la carpeta estableciendo la ip del servidor NFS.
mount $IP_NFS:/var/www/html /var/www/html