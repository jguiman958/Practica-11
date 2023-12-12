# Practica-11.-Instalación de un balanceador de carga en 3 niveles.

## Instalación del balanceador de carga en la máquina "Balanceador".
### ¿Qué se ha hecho?
<p>Hemos instalador una maquina que dispone que actua como balanceador de carga.</p>

<p>Estructura del balanceador de carga junto con los servidores frontend y backend:</p>

![Alt text](Capturas/Captura.PNG)

El ``objetivo`` que la máquina que sale a internet, el balanceador, tenga instalado apache, pero se tiene que instalar para que los diversos frontend que tengamos en la estructura de nuestra red, vayan alternando entre el uno y el otro, empleando el método de Round Robin, actuando los dos servidores frontend de forma conjunta, el balanceador de carga, deberá saber las direcciones ips privadas de los dos frontend, mas adelante se explica el porqué... sin embargo como introducción, viene bien saber que, la dirección pública que se da a internet va a ser la del balanceador, y el servidor apacher del ``balanceador`` previamente configurado por el administrador, se va a encargar de que vaya administrando contenido de los servidores frontend 1 y 2, es decir se van a ir turnando entre los dos, bajo las ordenes del balanceador.

## 1.-Instalación de la pila lamp en el balanceador.
### Pero,¿De que consta una pila LAMP?
Muy simple, con esto describimos un sistema de infraestructura de internet, lo que estamos buscando es desplegar una serie de aplicaciones en la web, desde un unico sistema operativo, esto quiere decir que, buscamos desplegar aplicaciones en la web de forma cómoda y rápida ejecutando un único script, el cual hay que configurar previamente.

### 1. Que representa cada letra de la palabra --> LAMP.

#### L --> Linux (Sistema operativo).
#### A --> Apache (Servidor web).
#### M --> MySQL/MariaDB (Sistema gestor de base de datos).
#### P --> PHP (Lenguaje de programación).

### Con esto, buscamos hacer un despligue de aplicaciones.

## --Script de la pila lamp para el balanceador de carga.

## Muestra todos los comandos que se han ejecutado.

```
set -ex
```

Ademas de que si hubiese un error, pararía el script en el momento en el que ocurre ese error.

## Actualización de repositorios

```
apt update
```

<p>Actualizamos los paquetes, para evitar errores en la instalación de software.</p>

## Invocamos al archivo source .env
<p>Cargamos el fichero .env para traer las variables necesarias al script cargadas desde ese fichero.</p>

```
source .env
```
Es decir:
```
IP_HTTP_SERVER_1=172.31.84.35
IP_HTTP_SERVER_2=172.31.90.171
```

Estas dos variables, las cuales contienen las ips privadas, de los dos servidores frontend.

## Instalamos el servidor Web apache

<p>Ahora vamos a instalar apache, ahora a partir de aquí comenzamos con los pasos proximos para que actúe como balanceador.</p>

```
apt install apache2 -y
```

## Habilitamos los modulos para configurar Apache como proxy apache

Necesitamos hacer que apache actue como un proxy... Pero ¿que es un proxy? Pongamos el caso en el que en una empresa tengamos una serie de equipos los cuales nos interesaría que no pudiesen acceder a cierto contenido en internet, pues el proxy se encarga de eso, el proxy permitirá o denegará cualquier paquete que pase por este, según lo haya configurado el administrador, el balanceador hará su papel como si fuese un proxy.

### Para ello:

```
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
```

Necesitamos instalar estas tres modalidades de apache basadas en el proxy, donde instalamos el proxy, el proxy_http y el balancer esto va a permitir que las peticiones de los frontend pasen por el balanceador.


## Habilitamos el balanceo de carga round robin.

```
a2enmod lbmethod_byrequests
```

Esto es una modalidad de apache para que el balanceo se pueda realizar mediante round robin.

## Copiamos el archivo de configuracion
Ahora, tenemos que contar con un fichero de configuración creado previamente llamado.

```
<VirtualHost *:80>
    <Proxy balancer://mycluster>
        # Server 1
        BalancerMember http://IP_HTTP_SERVER_1

        # Server 2
        BalancerMember http://IP_HTTP_SERVER_2
    </Proxy>

    ProxyPass / balancer://mycluster/
</VirtualHost>
```

Con esto, estamos configurando el balanceador proxy, el cual configuramos los dos frontend con sus ips privadas.

Donde BalancerMember incluye la ip privada de los frontend.

Las dos variables que van a sustituir ese contenido son:

```
IP_HTTP_SERVER_1=172.31.84.35
IP_HTTP_SERVER_2=172.31.90.171
```

Estas dos de aquí: IMPORTANTE tienen que ser las ips privadas de los dos servidores frontend.

```
cp ../conf/load-balancer.conf /etc/apache2/sites-available
```
Mediante cp cargamos ese fichero de configuración el cual configura el balanceador proxy del balanceador.

## Reemplazo las variables de la plantilla con las direcciones de los frontales.
```
sed -i "s/IP_HTTP_SERVER_1/$IP_HTTP_SERVER_1/" /etc/apache2/sites-available/load-balancer.conf
sed -i "s/IP_HTTP_SERVER_2/$IP_HTTP_SERVER_2/" /etc/apache2/sites-available/load-balancer.conf
```
Reemplazamos las variables:

```
BalancerMember http://IP_HTTP_SERVER_1
BalancerMember http://IP_HTTP_SERVER_2
```
Ahí es donde se van a poner esas direcciones privadas.

## Habilitamos el virtualhost que hemos creado.
```
a2ensite load-balancer.conf
```
Ahora habilitamos el sitio load-balancer.conf, para que muestre el contenido de los dos frontend.
## Deshabilitamos el virtual host por defecto.

```
a2dissite 000-default.conf
```
Teniendo en cuenta que necesitamos mostrar el contenido de los dos frontend a traves del balanceador, necesitamos deshabilitar el sitio por defecto que tiene apache2.

## Reiniciamos
Es necesario reiniciarlos para que se guarden los cambios en el servidor apache.
```
systemctl restart apache2
```

## Comprobaciones del Balanceador.
<p>Muestra de que el round robin funcione.</p>

![Alt text](Capturas/Captura1.PNG)

Si recargamos la pagina, en orden primero mostrará el frontend 1 y luego el frontend2.

# Instalaciones previas para instalar el balanceador.
<p>Para ello primero tenemos que tener instalado, las dos pilas lamp en sus respectivos frontend, los cuales serán el frontend 1 y frontend 2, en cada uno de los frontend debe ejecutarse el fichero install_lamp_frontend.</p>
# Actualización de repositorios
```
 sudo apt update
```
# Actualización de paquetes
# sudo apt upgrade  

# Instalamos el servidor Web apache
```
apt install apache2 -y
```
### Con esto instalamos el servidor web apache2.

### Estructura de directorios del servicio apache2.

```
 1. Directorios
  1.1 conf-available --> donde se aplican los hosts virtuales.
  1.2 conf-enabled --> donde se encuentran enlaces simbolicos a los archivos de configuracion           
  de conf-available.
  1.3 mods-available --> para añadir funcionalidades al servidor.
  1.4 mods-enabled --> enlaces simbolicos a esas funcionalidades.
  1.5 sites-available --> archivos de configuración de hosts virtuales.
  1.6 sites-enabled --> enlaces simbolicos a sites-available.
 2. Ficheros
  2.1 apache2.conf --> Archivo de configuración principal.
  2.3 envvars --> Define las variables de entorno, que se usan en el archivo principal.
  2.3 magic --> Para determinar el tipo de contenido, por defecto es MIME.
  2.4 ports.conf --> archivo donde se encuentran los puertos de escucha de apache.
```

### En /etc/apache2 se almacenan los archivos y directorios de apache2.

## Contenido del fichero /conf/000-default.conf.
Este archivo contiene la configuración del host virtual el cual debe contener las siguientes directivas para que funcione la aplicación web.

En la ruta del repositorio ``/conf/000-default.conf``, encontramos la configuración que se emplea para este despliegue.

```python
ServerSignature Off
ServerTokens Prod
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html 
    
    <Directory "/var/www/html/">
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Aquí podemos comprobar lo que contiene el fichero de configuración del ``VirtualHost``, donde todas las conexiones pasaran por el puerto 80, el ``DocumentRoot``, donde mostrará el contenido será desde ``/var/www/html`` y podemos ver los archivos de error y acceso para comprobar errores y ver quien ha accedido, Tambien, tenemos la directiva ``Directory index`` la cual establece una prioridad en el orden que se establezca.

Podemos comprobar que hemos añadido ``directory`` el cual almacena las directivas asignadas al virtualhost, mas las que se encuentran en el archivo principal de apache. 

La ruta donde se ejecuta el contenido que vamos a mostrar por internet y la directiva ``AllowOverride All`` mas adelante se explica el porque esto está aquí, como información puedo ofrecer que tiene que ver con el archivo ``.htaccess``.

### También se hace uso de las siguientes directivas 
``ServerSignature OFF `` --> Esto es por si nos interesa incorporar la versión de apache, en páginas de error e indice de directorios, lo dejamos en OFF por seguridad. Se debe aplicar a todo el servidor.

``ServerTokens Prod `` --> Esta se puede aplicar a un único servidor virtual. Aquí se muestran información sobre las cabeceras, es decir, respuestas que se mandan al cliente, es conveniente tenerlo quitado.

# Instalar php
```
apt install php libapache2-mod-php php-mysql -y
```
### Instalamos php junto con unos modulos necesarios.
<------------------------------------------------------>
### ``libapache2-mod-php`` --> para mostrar paginas web desde un servidor web apache y ``php-mysql``, nos permite conectar una base de datos de MySQL desde PHP.

# Copiar el archivo de configuracion de apache.
```
cp ../conf/000-default.conf /etc/apache2/sites-available
```
### En este caso, no haría falta emplear el comando ``a2ensite``, ya que se habilita por defecto debido a que apache2 toma por defecto la configuración de ese archivo para desplegar las opciones que hemos hecho en la web.

### Este script posee un archivo de configuración en la carpeta ``conf `` por el cual configura el host virtual que muestra el contenido de la aplicación web.

```
ServerSignature Off
ServerTokens Prod
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html
    
    <Directory "/var/www/html/">
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

# Reiniciamos el servicio apache
```
systemctl restart apache2
```
### Reiniciamos apache para que obtenga los cambios.

# Copiamos el arhivo de prueba de php
### La finalidad de esto va a ser que muestre el contenido de la página index.php la cual se inserta en la carpeta html, con objetivo de que muestre el contenido de esa página, por defecto, si vemos el archivo de configuración de 000-default.conf veremos que:
 <p> DocumentRoot ``/var/www/html`` --> Toma como raiz, los archivos en html.</p>
 <p> ``DirectoryIndex`` --> index.php index.html --> Muestra en orden los archivo situados.</p>    

```
cp ../php/index.php /var/www/html
```
### Sabiendo lo anterior copiamos el archivo index.php a ``/var/www/html``.

# Modificamos el propietario y el grupo del directo /var/www/html
```
chown -R www-data:www-data /var/www/html
```
### Lo que estamos haciendo es que el usuario de apache tenga permisos de propietario sobre, el directorio html con objetivo de que pueda desplegar el **sitio web**.

# Modificación del archivo index de los servidores frontend1 y frontend2.
<p>Para ello tenemos que insertar lo siguiente para comprobar el funcionamiento del load_balancer y ver si funciona o no, esto es solo un ejemplo, de que funciona como debe.</p>

Primero tenemos que borrar el que se crea con la instalación de apache2.
```
sudo rm -rf index.html
```
Para ello podemos borrar el archivo index.html que tenga por defecto apache y crear otro que incluya lo siguiente, o lo que queráis.
```
sudo nano /var/www/html/index.html
```
Dentro del archivo ponemos Frontend 1 o Frontend 2 dependiendo del frontend en el que estéis.

# 2 Instalación de certbot y sitio web con certificado transmitido por autoridad certificadora.

<p>Pero, ¿Que es una autoridad certificadora? Nos permite que el acceso a nuestro contenido web se cifre y sea seguro, hoy dia no se permite el uso de paginas http sin el protocolo ssl/tls, con el que cifra los datos durante las peticiones.</p>

### Muestra todos los comandos que se han ejecutado.
<p>-- Aparte de que interrumpe el script en caso de errores.</p>

```
set -ex
```
## 1 Actualización de repositorios

```
 apt update
```
<p>Actualizamos los repositorios para que el software se instale correctamente y no de pié a errores durante la ejecución del script.</p>

## 2 Importamos el archivo de variables .env

```
source .env
```

<p>El cual las variables que nos interesan de este archivo son las siguientes:</p>

```
# Variables para el certificado.
CERTIFICATE_EMAIL=demo@demo.es
CERTIFICATE_DOMAIN=juanjoseguirado.ddns.net
```

<p>Estas son las variables que requerimos para la creación del certificado el cual a traves de una autoridad certificadora de confianza, nos va a secuerizar el contenido, mediante https, cogiendo el dominio que he creado con noip y asignando a ese dominio la ip de la máquina con la que se pretende realizar el despliegue.</p>

Esto se realizará automaticamente con certbot, ya que junto con letsencrypt se encargará el de establecer el certificado seguro.

## 3 Borramos certbot para instalarlo despues, en caso de que se encuentre, lo borramos de apt para instalarlo con snap.
#
```
apt remove certbot
```
Con esto desinstalamos certbot por si se haya en el sistema.

#Instalación de snap y actualizacion del mismo.
```
snap install core
snap refresh core
```
Instalamos y ejecutamos el gestor de paquetes snap, el cual lo necesitamos para instalar certbot.

## 4 Instalamos la aplicacion certbot

```
snap install --classic certbot
```

### Donde --classic hace que dicha aplicación se instale, con una serie de permisos para que forme parte de un entorno seguro y aislado teniendo acceso a recursos del sistema que a lo mejor no podría tener.

## 5 Creamos un alias para la aplicacion certbot

```
ln -sf /snap/bin/certbot /usr/bin/certbot
```

### Creamos un enlace simbólico donde:

```python
ln --> Para crear un enlace en el sistema.
-s --> El tipo de enlace que crea es simbólico.
-f --> Para que lo cree por la fuerza.
```

Tras eso, hemos creado un enlace simbolico en ``/usr/bin`` para que se ejecute una vez lo llamamos, es decir para que se ejecute, es necesario ya que necesitamos que se ejecute para recibir ese certificado de confianza.

## 6 Obtener el certificado.

```
certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive
```

Nosotros si solo insertasemos ``certbot --apache``, lo ejecutaría pero, interrumpería la automatización del script, ya que buscamos que se realice automáticamente, esto se debe a que aparecen asistentes donde hay que insertar una serie de datos.

```python
--apache: Esto significa que da el certificado para apache.
-m: Establecemos la direccion de correo la cual la contiene la variable $CERTIFICATE_EMAIL del archivo .env, se puede cambiar por otra.
--agree-tos: Con esto aceptamos terminos de uso.
--no-eff-email: Con esto no compartimos nuestro email con la EFF.
-d: El dominio que contiene la variable: $CERTIFICATE_DOMAIN.
--non-interactive: Para que declarar que se hace de forma no interactiva. 
```
<p>Una vez que hemos instalado las pilas del frontend y el backend en sus respectivos servidores, hacer un despliegue del backend y frontend en sus respectivas máquinas, hay que tener en cuenta que el frontend no requiere de mysql, al igual que el backend no necesita ni php ni apache, ni nada ya que no sirve de nada que la gente se conecte a la base de datos.</p>

# Instalaciones previas tras instalar el balanceador.

<p>Para ello primero tenemos que tener instalado, las dos pilas lamp en sus respectivos frontend, los cuales serán el frontend 1 y frontend 2, en cada uno de los frontend debe ejecutarse el fichero install_lamp_frontend.</p>
# Actualización de repositorios

```
apt update
```

# Actualización de paquetes
# sudo apt upgrade  

# Instalamos el servidor Web apache
```
apt install apache2 -y
```
### Con esto instalamos el servidor web apache2.

### Estructura de directorios del servicio apache2.

```
 1. Directorios
  1.1 conf-available --> donde se aplican los hosts virtuales.
  1.2 conf-enabled --> donde se encuentran enlaces simbolicos a los archivos de configuracion           
  de conf-available.
  1.3 mods-available --> para añadir funcionalidades al servidor.
  1.4 mods-enabled --> enlaces simbolicos a esas funcionalidades.
  1.5 sites-available --> archivos de configuración de hosts virtuales.
  1.6 sites-enabled --> enlaces simbolicos a sites-available.
 2. Ficheros
  2.1 apache2.conf --> Archivo de configuración principal.
  2.3 envvars --> Define las variables de entorno, que se usan en el archivo principal.
  2.3 magic --> Para determinar el tipo de contenido, por defecto es MIME.
  2.4 ports.conf --> archivo donde se encuentran los puertos de escucha de apache.
```

### En /etc/apache2 se almacenan los archivos y directorios de apache2.

## Contenido del fichero /conf/000-default.conf.
Este archivo contiene la configuración del host virtual el cual debe contener las siguientes directivas para que funcione la aplicación web.

En la ruta del repositorio ``/conf/000-default.conf``, encontramos la configuración que se emplea para este despliegue.

```python
ServerSignature Off
ServerTokens Prod
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html 
    
    <Directory "/var/www/html/">
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Aquí podemos comprobar lo que contiene el fichero de configuración del ``VirtualHost``, donde todas las conexiones pasaran por el puerto 80, el ``DocumentRoot``, donde mostrará el contenido será desde ``/var/www/html`` y podemos ver los archivos de error y acceso para comprobar errores y ver quien ha accedido, Tambien, tenemos la directiva ``Directory index`` la cual establece una prioridad en el orden que se establezca.

Podemos comprobar que hemos añadido ``directory`` el cual almacena las directivas asignadas al virtualhost, mas las que se encuentran en el archivo principal de apache. 

La ruta donde se ejecuta el contenido que vamos a mostrar por internet y la directiva ``AllowOverride All`` mas adelante se explica el porque esto está aquí, como información puedo ofrecer que tiene que ver con el archivo ``.htaccess``.

### También se hace uso de las siguientes directivas 
``ServerSignature OFF `` --> Esto es por si nos interesa incorporar la versión de apache, en páginas de error e indice de directorios, lo dejamos en OFF por seguridad. Se debe aplicar a todo el servidor.

``ServerTokens Prod `` --> Esta se puede aplicar a un único servidor virtual. Aquí se muestran información sobre las cabeceras, es decir, respuestas que se mandan al cliente, es conveniente tenerlo quitado.

# Instalar php
```
apt install php libapache2-mod-php php-mysql -y
```
### Instalamos php junto con unos modulos necesarios.
<------------------------------------------------------>
### ``libapache2-mod-php`` --> para mostrar paginas web desde un servidor web apache y ``php-mysql``, nos permite conectar una base de datos de MySQL desde PHP.

# Copiar el archivo de configuracion de apache.
```
cp ../conf/000-default.conf /etc/apache2/sites-available
```
### En este caso, no haría falta emplear el comando ``a2ensite``, ya que se habilita por defecto debido a que apache2 toma por defecto la configuración de ese archivo para desplegar las opciones que hemos hecho en la web.

### Este script posee un archivo de configuración en la carpeta ``conf `` por el cual configura el host virtual que muestra el contenido de la aplicación web.

```
ServerSignature Off
ServerTokens Prod
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html
    
    <Directory "/var/www/html/">
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

# Reiniciamos el servicio apache
```
systemctl restart apache2
```
### Reiniciamos apache para que obtenga los cambios.

# Copiamos el arhivo de prueba de php
### La finalidad de esto va a ser que muestre el contenido de la página index.php la cual se inserta en la carpeta html, con objetivo de que muestre el contenido de esa página, por defecto, si vemos el archivo de configuración de 000-default.conf veremos que:
 <p> DocumentRoot ``/var/www/html`` --> Toma como raiz, los archivos en html.</p>
 <p> ``DirectoryIndex`` --> index.php index.html --> Muestra en orden los archivo situados.</p>    

```
cp ../php/index.php /var/www/html
```

### Sabiendo lo anterior copiamos el archivo index.php a ``/var/www/html``.

# Modificamos el propietario y el grupo del directo /var/www/html

```
chown -R www-data:www-data /var/www/html
```

### Lo que estamos haciendo es que el usuario de apache tenga permisos de propietario sobre, el directorio html con objetivo de que pueda desplegar el **sitio web**.

# Modificación del archivo index de los servidores frontend1 y frontend2.
<p>Para ello tenemos que insertar lo siguiente para comprobar el funcionamiento del load_balancer y ver si funciona o no, esto es solo un ejemplo, de que funciona como debe.</p>

Primero tenemos que borrar el que se crea con la instalación de apache2.

```
rm -rf index.html
```

Para ello podemos borrar el archivo index.html que tenga por defecto apache y crear otro que incluya lo siguiente, o lo que queráis.

```
nano /var/www/html/index.html
```

Dentro del archivo ponemos Frontend 1 o Frontend 2 dependiendo del frontend en el que estéis.

## Instalación del Servidor NFS.

<p>Importante visualizar el archivo **nfsserver.sh**</p>

## Muestra todos los comandos que se han ejeutado.

```
set -ex
```

Esto muestra lo que hay y detiene el script.

## Actualización de repositorios

```
 apt update
```

## Incluimos las variables del archivo .env.

```
source .env
```

```
Estas variables son las que necesitamos:
NFS_FRONTEND_NETWORK=172.31.0.0/16 # RANGOS DE IPS DE CLIENTES 

IP_NFS=172.31.93.41 #--> IP PRIVADA DEL SERVIDOR NFS
```

## Instalamos nfsserver.

```
apt install nfs-kernel-server -y
```
Para hacer el servidor nfs.

## Creamos el directorio que queremos compartir.

Creamos el directorio que vamos a compartir con los frontend1 y 2.
```
mkdir -p /var/www/html
```

## Damos permisos especiales.

Cambiamos el propietario del html a nobody-nogroup.
```
chown nobody:nogroup /var/www/html
```

## Editamos el archivo /etc/exports

```
cp ../exports/exports /etc/exports
```

Incorporamos el archivo exports al etc. Con lo siguiente:

```
/var/www/html NFS_FRONTEND_NETWORK(rw,sync,no_root_squash,no_subtree_check)
```

Esa variable se sustituye por el rango de ips al que pertenece la red con la que trabajamos.

## Cambiamos el contenido del export para incorporar la ip privada del servidor nfs. 

```
sed -i "s#NFS_FRONTEND_NETWORK#$NFS_FRONTEND_NETWORK#" /etc/exports
```

Con eso cambiamos la ip.

## Reiniciamos el servicio de nfs. 

```
systemctl restart nfs-kernel-server
```

Reiniciamos el servicio para que actualice los cambios.

Y pasamos al cliente... es decir los frontend....

## Instalación del cliente nfs.

<p>En cada uno de los frontend:</p>

## Muestra todos los comandos que se han ejecutado.

```
set -ex
```

## Actualización de repositorios

```
apt update
```

## Incluimos las variables del archivo .env.

```
source .env
```


## Instalacion de paquetes necesarios en el cliente nfs.

```
apt install nfs-common -y
```

Instalamos el cliente de nfs para frontend 1 y 2.

## Montaje de la carpeta estableciendo la ip del servidor NFS.

```
mount $IP_NFS:/var/www/html /var/www/html
```

Montamos la ip del servidor nfs con la ruta de origen de ese servidor en el destino del frontend1.

## Para que la unidad se monte automaticamente y con los >> me añade al final en el /etc/fstab para que al reiniciar se monte sola, tras el reinicio.

```
echo "$IP_NFS:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
```
Esto hace que el montaje sea permanente en el sistema.

## Ver el contenido compartido en el frontend 1 y 2.

```
df -h 
```
Con esto vemos si /var/www/html se ha compartido.

## Creación de la base de datos.
# Instalamos mysql-server para la máquina backend.

## Actualización de repositorios
 
 ```
 sudo apt update
 ```
Con esto actualizamos los repositorios.  

## Importamos el archivo .env para incorporar las variables que necesitamos.

```
source .env
```

Incorporamos la variable que necesitamos para la instalación.

```
MYSQL_PRIVATE=172.31.85.31
```

Esta variable, incorpora la ip privada del backend, ya que poner la pública sería algo no recomendable de hacer, en la base de datos solo deben trabajar los empleados, lo usuarios que accedan al frontend no deben tener ningún conocimiento sobre el lugar donde reside la base de datos.

## Instalación de mysql-server

```
apt install mysql-server -y
```

Instalamos mysql-server conn el -y para que lo isntale de forma automática.

## Configuración de mysql, para que solo acepte conexiones desde la ip privada.

```
sed -i "s/127.0.0.1/$MYSQL_PRIVATE/" /etc/mysql/mysql.conf.d/mysqld.cnf
```

<p>No nos interesa que mysql se conecte a si mismo, es decir que se redireccione a si mismo mediante el host local, tenemos que poner la ip privada de dicho servidor, que es donde se va a encontrar alojado el servidor de mysql.</p>

## Reiniciamos el servicio.

```
systemctl restart mysql
```
<p>Importante reiniciar el servicio tras ese leve ajuste en el fichero de configuración de mysql.</p>

# Creamos la base de datos para el Backend.

<p>"Aquí es donde ejecutamos el script deploy_backend."</p>

```
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
```

<p>Con estas instrucciones se crean la base de datos para wordpress desde la máquina backend.</p>

## Reiniciamos el servicio de mysql.

<p>Es necesario reiniciar el servicio para que se asimilen los cambios.</p>

```
systemctl restart mysql 
```

Y con esto, ya estaría correctamente configurado, el balanceador de carga con apache, donde previamente hemos mostrado, que ejecuta bien el proxy que actua como balanceador, mostrando el contenido de los 2 frontend mediante una serie de turnos.

# Instalación en el frontend.

## Actualización de repositorios

Necesario para que a la hora de instalar software no de errores.

```
apt update
```

## Incluimos las variables del archivo .env.
```
source .env
```
Las cuales son las siguientes variables:

```
# Configuramos variables

# Ips privadas de los dos frontend, conectadas mediante http al balanceador de carga.
#-------------------------------#
IP_HTTP_SERVER_1=172.31.84.35 #--> Frontend 1
IP_HTTP_SERVER_2=172.31.90.171 #--> Frontend 2
#-------------------------------#

# Base de datos de wordpress.
#-----------------------------#
WORDPRESS_DB_NAME=wordpress

WORDPRESS_DB_USER=wp_user

WORDPRESS_DB_PASSWORD=wp_pass

IP_CLIENTE_MYSQL=172.31.% #--> Ip privada del frontend que se conecta a la base de datos

WORDPRESS_DB_HOST=172.31.95.31 #--> Base de datos con el servidor de mysql.
#-----------------------------#

# Configuración post instalacion de wordpress.
#-----------------------------#
wordpress_title="Sitio web de IAW"
wordpress_admin_user=admin
wordpress_admin_pass=admin
wordpress_admin_email=demo@demo.es
#-----------------------------#


# Variables para el certificado.
#-----------------------------#
CERTIFICATE_EMAIL=demo@demo.es
CERTIFICATE_DOMAIN=juanjoseguirado.ddns.net
#-----------------------------#

# Ip de mysql
#-----------------------------#
MYSQL_PRIVATE=172.31.95.31 #--> Ip del servidor privado de mysql.
#-----------------------------#

# Actualizacion del login para ocultar el login del frontend
#-----------------------------#
WORDPRESS_HIDE_LOGIN=acceso
#-----------------------------#
```

## Borramos los archivos previos.
```
rm -rf /tmp/wp-cli.phar
```

Borramos los archivo del directorio tmp para que no se acumulen.

## Descargamos La utilidad wp-cli

```
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
```
Necesaria para instalar wordpress por comandos.

## Asignamos permisos de ejecución al archivo wp-cli.phar

```
chmod +x /tmp/wp-cli.phar
```
Damos permisos de ejecución a fichero, para poder ejecutarlo como un comando proximamente. 

## Movemos los el fichero wp-cli.phar a bin para incluirlo en la lista de comandos.

```
mv /tmp/wp-cli.phar /usr/local/bin/wp
```

Mandamos wp a bin para que se pueda ejecutar como un comando.

## Eliminamos instalaciones previas de wordpress

```
rm -rf /var/www/html/*
```
Borramos todo del directorio que muestra el contenido de la aplicación web. 

## Descargarmos el codigo fuente de wordpress en /var/www/html

```
wp core download --path=/var/www/html --locale=es_ES --allow-root
```
Descargamos el codigo fuente de wordpres.

## Creación del archivo wp-config 

```
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=/var/www/html \
  --allow-root
```
Creamos el archivo vp config con los datos necesarios de la base de datos.

```
WORDPRESS_DB_NAME=wordpress

WORDPRESS_DB_USER=wp_user

WORDPRESS_DB_PASSWORD=wp_pass

WORDPRESS_DB_HOST=172.31.95.31 #--> Base de datos con el servidor de mysql.
```

Contiene la forma de poder acceder a la base de datos.

## Instalar wordpress.

```
wp core install \
  --url=$CERTIFICATE_DOMAIN \
  --title="$wordpress_title" \
  --admin_user=$wordpress_admin_user \
  --admin_password=$wordpress_admin_pass \
  --admin_email=$wordpress_admin_email \
  --path=/var/www/html \
  --allow-root
```

Seguidamente, instalamos wordpress declarando la ruta donde se encuentra wordpress y permitiendo el acceso al root para poder instalarlo.

Dando como información las siguientes variables, para que la instalación se haga de forma automática.

```
wordpress_title="Sitio web de IAW"
wordpress_admin_user=admin
wordpress_admin_pass=admin
wordpress_admin_email=demo@demo.es
CERTIFICATE_DOMAIN=juanjoseguirado.ddns.net
```
Tomando como ruta url, el dominio creado con no ip.

## Actualizamos el core

```
wp core update --path=/var/www/html --allow-root
```
Actualizamos el core de wordpress.

## Instalamos un tema:

```
wp theme install sydney --activate --path=/var/www/html --allow-root
```

Instalamos un tema en wordpress.

## Instalamos el plugin bbpress:

```
wp plugin install bbpress --activate --path=/var/www/html --allow-root
```

Instalamos un plugin en wordpress.

## Configuramos la variables https = on.

```
sed -i "/COLLATE/a \$_SERVER['HTTPS'] = 'on';" /var/www/html/wp-config.php
```

Habilitamos https en wp-config para que cargue el contenido con http de forma segura, ya que si no cambiamos la opción a on no mostrará el contenido como debe ya que lo carga con http en vez de https en el navegador.

## Instalamos el plugin para ocultar wp-admin

```
wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root
```

Importante para mejorar la seguridad de wordpress y ocultar el login.

## Habilitar permalinks

 ```
 wp rewrite structure '/%postname%/' \
  --path=/var/www/html \
  --allow-root
```

Con esto realizamos un rewrite, ya que es necesario que para que las paginas ganen cierta fama para google, con objetivo de mejorar el seo, añadimos esto para que en las url aparezcan nombres en vez de parametros inconclusos.

## Modificamos automaticamente el nombre que establece por defecto el plugin wpd-hide-login

```
wp option update whl_page $WORDPRESS_HIDE_LOGIN --path=/var/www/html --allow-root
```

Cambiamos el nombre del login por defecto de wordpress al declarado en la variables...

```
WORDPRESS_HIDE_LOGIN=acceso
```

## Creamos el archivo htaccess en /var/www/html

```
cp ../conf/.htaccess /var/www/html
```

El cual dicho archivo contiene lo siguiente, con algunas explicaciones.

```
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On Habilita el motor de reescritura.
RewriteBase / Define la ruta para la reescritura.
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```

Así es como se ve en el archivo, el contenido de htaccess, este se crea solo allí sin que sea necesario crearlo previamente.

## Habilitamos el modulo mod_rewrite de apache.

```
a2enmod rewrite
```

<p>Habilitamos el módulo rewrite, para que htaccess tome acción aquí y funcione según la condición, ya que en el archivo que estamos trabajando:</p>

```
ServerSignature Off
ServerTokens Prod
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html

    <Directory "/var/www/html/">
        AllowOverride All
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Tenemos esta directiva AllowOverride All la cual permite que htaccess pueda funcionar.


## Cambiamos al propietario de /var/www/html como www-data

```
chown -R www-data:www-data /var/www/html
```

Y damos permiso al usuario www-data de apache al directorio html.