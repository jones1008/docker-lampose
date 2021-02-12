# Docker Development Setup

# Intro: What is this Docker setup?

This Docker development setup is mainly setup with the `docker-compose.yml` file. 
It creates two containers at startup (`web` and `db`).

The `web` container runs Debian (Linux) and is responsible for the web application.
The current directory will be available in the `/var/www/html` directory of the web application.


The `db` container runs Alpine Linux (very small Linux).
It holds the database server and is therefore responsible for managing database connection etc. 


# Configure and run the dockerized application:

### 1. Create `.env` file
copy `.env.sample` to `.env`

### 2. Set some important variables
Set your project name in the `.env` file like so:
```dotenv
COMPOSE_PROJECT_NAME=my-project
```
This prevents container name collisions in the future.
___

Set an **unused loopback IP** from the IP range `127.0.0.0/8` in your `.env` file. 
Unused means the loopback IP does not appear in your `hosts` file. For example:
```dotenv
LOOPBACK_IP=127.55.0.1
```
This is needed to configure a custom domain where your application will be available at.
___
Set a custom domain where your application will be available at:
```dotenv
DOMAIN=test.docker
```
___
Set the absolute path to your `hosts` file on your OS:
```dotenv
HOSTS_FILE=/c/Windows/System32/drivers/etc/hosts    # use this for Windows
#HOSTS_FILE=/etc/hosts                              # use this for Linux
#HOSTS_FILE=/private/etc/hosts                      # use this for MacOS
```
This is needed to automatically set your domain in your hosts file.

>**Important**: Make sure your `hosts` file is writable. On Windows this is done like this:
![_docker/docs/writable-hosts-file.png](_docker/docs/writable-hosts-file.png)

### 3. Database
#### Config:
[comment]: <> (TODO: Passwort überhaupt notwendig?)
Set a password for all your databases of this project in the `.env` file:
```dotenv
MYSQL_ROOT_PASSWORD=password
```
#### Import at initial startup:
To import a database at **initial** docker startup move a `.sql` file to `./_docker/db/sql`

> An `.sql` file named `test.sql` will import this file into a database named `test`. 
> So name your `.sql` file how you want your database to be named. 

To import multiple databases, just place multiple `.sql` files in this directory.

**Important**: If the container is already running, stop it, tear it down and start it again to trigger the import:
```shell
docker-compose down
docker-compose up
```

### 4. Download and configure Docker Desktop
If you are on Windows or Mac download and install [Docker Desktop](https://www.docker.com/get-started) if you haven't already.

If you are on Winodws make sure to **disable the WSL 2 based engine** and use the Hyper-V backend instead as this can lead to performance issues with docker volumes (10x faster).

This can be done in the Docker Desktop Dashboard:
![_docker/docs/hyper-v.png](_docker/docs/hyper-v.png)

### 5. Start your containers
After configuration you can start your containers with executing the following command **in the root directory of your project**:
```shell
docker-compose up
```
Make sure to start the docker daemon first ([Docker Desktop](https://www.docker.com/get-started)).

The first time executing this takes a few minutes.

> **Tip**: The Dashboard of Docker Desktop can be quite useful to manage your containers.


### 6. Connect to database (client or application)
You can connect to the database from inside (database config of your application) and outside of docker (for example [DBeaver](https://dbeaver.io/)) with the following credentials:
- host: the `DOMAIN` you specified in your `.env` file
- port: `3306`
- user: `root`
- password: specified with `MYSQL_ROOT_PASSWORD` in `.env` file
- database name: specified with the basename of your imported `.sql` file (e.g.: file `test.sql` -> database name `test`)


### 7. Open Application
#### Local
To open the application frontend open `http://<DOMAIN>` in your browser.

You can configure your `DOMAIN` in `.env` file. Make sure to restart the containers after changing it:
```dotenv
DOMAIN=test.local
```
#### https
The application is also available at `https://<DOMAIN>` per default.

#### On the network
If you want to access your application from **another device on the same network**, set `EXTERNAL_IP` in your `.env` 
file to the IP your computer has on the corresponding network interface. **For example**:
```dotenv
EXTERNAL_IP=192.168.178.54
```
After you restarted your container, the application will be available at `http://192.168.178.54` on the network you are connected to.

### 8. xdebug
xdebug is **installed and enabled by default**.

To disable xdebug with PHP version `< 7.2` change the file `./_docker/web/additional-inis/xdebug.ini` to:
```ini
xdebug.remote_enable=0
```
To disable xdebug with PHP version `>= 7.2` change the file `./_docker/web/additional-inis/xdebug.ini` to:
```ini
xdebug.mode=off
```
To enable xdebug with PHP version `>= 7.2` change the file `./_docker/web/additional-inis/xdebug.ini` to:
```ini
xdebug.mode=debug
```
After that you need to restart the container.


### 9. Configure WKHTMLTOPDF
If installed the wkhtmltopdf binary will be available **in** the container under `/usr/bin/wkhtmltopdf`, so set this path in your application settings.


### 10. Composer, npm and other commands
Composer and npm is preinsalled in the `web` container.

`composer install` and `npm install` is automatically executed at container startup if configured.

If you want to manually execute another command, it is best to execute it **in** the container:
```bash
docker exec -it web-<COMPOSE_PROJECT_NAME> /bin/bash  # go into container
composer <any-composer-command>
npm <any-npm-command>
<any-other-command>
```
`COMPOSE_PROJECT_NAME` is defined in your `.env` file




# Dockerize the application:


### Note 1:
If you make any changes to one of the following files:
- any `Dockerfile`

make sure to rebuild it:
```shell
docker-compose build
```
After that you can start it again with:
```shell
docker-compose up
```

## Configuration:

### 1. PHP setup
To specify the **PHP version** change the `FROM` command in `./_docker/web/Dockerfile`

e.g. for PHP version 5.6:
```dockerfile
FROM php:5.6-apache
```
After that make sure to build this container again (see Note 1 above)

#### PHP Extensions:
To install and enable **PHP extensions** add them to `./_docker/web/Dockerfile`.
```dockerfile
RUN install-php-extensions <extensionname>
```
If this did not work try this:
```dockerfile
RUN docker-php-ext-install <extensionname>
```
All available extensions see here: https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions

More information on https://hub.docker.com/_/php/ at *How to install more PHP extensions*

#### Config:
To edit any `php.ini` config, just add another `.ini` file to `_docker/web/additional-inis/`


### 2. Webserver Setup
If you need to set the root directory of your web application other than `./` 
(for example `/webroot`) set it in `_docker/web/sites-available/000-default.conf`:
```apacheconf
# ...
DocumentRoot /var/www/html/webroot
```

### 3. Database configuration
If you need to configure some database parameters (for example `innodb_file_format`), you can do that in the `_docker/db/my.cnf` file.


### 4. Install Composer
Composer is installed per default, and it runs `composer install` at startup if you set the path where it is executed with the following environment variable in your `docker-compose.yml`:
```yaml
services:
  web:
    # ...
    environment:
      COMPOSER_INSTALL_PATHS: ./
```
If you need to execute `composer install` in multiple paths you can do this by separating them by a `:`:
```yaml
COMPOSER_INSTALL_PATHS: ./path:./another/path
```


### 5. Run `npm install` at startup
Node.js and `npm` is installed per default, and it automatically runs `npm install` in the directory you specified with:  
```yaml
services:
  web:
    # ...
    environment:
      NPM_INSTALL_PATHS: ./path/to/sub/dir
```
If you need to execute `npm install` in multiple paths you can do this by separating them by a `:`:
```yaml
NPM_INSTALL_PATHS: ./path:./another/path
```


### 6. install wkhtmltopdf
If you want to install [wkhtmltopdf](https://wkhtmltopdf.org) as a depencency change the `docker-compose.yml` to:
```yaml
services:
  web:
    build:
      # ...
      args:
        INSTALL_WKHTMLTOPDF: "true"
```
After that you have to rebuild the container (see Note 1)


## Troubleshoot
#### bash into container:
To troubleshoot anything inside a container, go into the container with:
```shell
docker exec -it <container-name> /bin/bash
```
If this doesn't work try this:
```shell
docker exec -it <container-name> /bin/sh
```


# Roadmap
* [x] initial composer install execution within docker container
* [x] use of docker alpine packages to create smaller container
* [x] set webroot of web application
* [x] move wkhtmltopdf and composer to another dependency, and not .env bc it is git dependent
* [x] Split Documentation in "Dockerize your application", "Run your application in Docker"
* [x] support for multiple sql files imported into seperate databases
* [x] add my.cnf for easier configuration
* [x] performance improvements (switch to hyper-v)
* [x] echo of localhost:<port> after starting container
* [x] further installation logic (composer install, npm install, etc...)
* [x] some method to run several projects at the same time without port collision and easy access to web and database
* [x] automatic adding of host resolution to hosts file with startup script
* [x] make npm and composer available in main container
* [x] fix startup.sh output when DOMAIN is undefined
* [x] support for multiple npm/composer install directories
* [x] easier mariadb connection setup
* [x] access from another device in the network
* [x] setup for https connections (sgv project?)
* [x] fix database connection
* [x] fix hosts file script
* [x] add output `started at http://192.15.34.5 + https?` to `startup.sh`
* [x] get rid of apache2-foreground ssl:warnings
* [ ] test WKHTMLTOPDF in application (copy db + get salt from production)
* [ ] install grunt into container
* [ ] dockerize IFAA (Genesis World, ERP, Shop)
* [ ] hostsfile script error:
```
###127.55.0.3 test.docker
##127.55.0.4 test.docker
#127.55.0.5 test.docker
```
* [ ] npm and composer install with wildcard (recursive) directory syntax (https://github.com/wikimedia/composer-merge-plugin -> https://github.com/wikimedia/composer-merge-plugin/pull/189 ?)
* [ ] automate config files more - "template"-language, that dynamically replaces ${VARIABLES} of config files and maps them with volumes
* [ ] bti-brandschutz: git submodule für bti-brandschutz-templates festelegen