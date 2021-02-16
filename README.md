# Docker Development Setup

# Intro: What is this Docker setup?

This Docker development setup is mainly setup with the `docker-compose.yml` file. 
It creates two containers at startup (`web` and `db`).

The `web` container runs Debian (Linux) and is responsible for the web application.
The current directory will be available in the `/var/www/html` directory of the web application.


The `db` container runs Alpine Linux (very small Linux).
It holds the database server and is therefore responsible for managing database connection etc. 

## Prefix Notes
### Git submodules
If your application has **git submodules** make sure to pull them first. 
If you have a `.gitmodules` file in your root directory you will probably want to do this. 
```shell
git submodule update --init --recursive
```

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
#### Import at initial startup:
To import a database at **initial** docker startup move a `.sql` file to `./_docker/db/sql`

After that map this file to a database name of your choice in your `.env` file:
```dotenv
DATABASE_NAME_MAIN=test_name
DATABASE_FILE_MAIN=test.sql
```
This will import the file `./_docker/db/sql/test.sql` in the newly created database `test_name` at container startup within the `db` container.

To import **multiple** databases, add another `.sql` file and add more mapping variables with another suffix than `_MAIN` like above.

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

#### Port error
If you get an error like:
```
Ports are not available: listen tcp 127.55.0.1:3308: bind: Der Zugriff auf einen Socket war aufgrund der Zugrifssrechte des Sockets unzulässig.
```
You have to change the corresponding port in you `.env` file to a port that is available on your local system. **For example**:
```dotenv
WEB_PORT: 8081
WEB_PORT_SSL: 4443
DB_PORT: 3309
```

### 6. Connect to database (client)
You can connect to the database (for example [DBeaver](https://dbeaver.io/)) with the following credentials:
- host: the `DOMAIN` variable you specified in your `.env` file
- port: the `DB_PORT` variable you specified in your `.env` file
- user: `root`
- password: `root` (if not specified differently in `docker-compose.yml` with the environment variable `MYSQL_ROOT_PASSWORD` of the `db` container)
- database name: the `DATABASE_FILE_MAIN` or `DATABASE_FILE_<OTHER_SUFFIX>` you specified in your `.env` file


### 7. Open Application
#### Local
To open the application frontend open `http://<DOMAIN>:<WEB_PORT>` in your browser.

You can configure your `DOMAIN` in `.env` file. Make sure to restart the containers after changing it:
```dotenv
DOMAIN=test.local
```
#### https
The application is also available at `https://<DOMAIN>:<WEB_PORT_SSL>` per default.

#### On the network
If you want to access your application from **another device on the same network**, set `EXTERNAL_IP` in your `.env` 
file to the IP your computer has on the corresponding network interface. **For example**:
```dotenv
EXTERNAL_IP=192.168.178.54
```
After you restarted your container, the application will be available at `http://192.168.178.54:<WEB_PORT>` on the network you are connected to.

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


### 9. Composer, npm, grunt and other commands
Composer, npm and grunt is pre-installed in the `web` container.

`composer install` and `npm install` is automatically executed at container startup if configured.

If you want to manually execute another command, it is best to execute it **in** the container:
```bash
docker exec -it web-<COMPOSE_PROJECT_NAME> /bin/bash  # go into container
composer <any-composer-command>
npm <any-npm-command>
grunt
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


### 4. Custom application configuration files
If you have a git ignored file (for example a `database_config.php`) in your application that normally needs to be edited,
you can define a template file, that reduces further configuration of the Docker user.

At container startup all environment variable occurrences within this file will be set to the corresponding value and
copied to the defined location.

To do this, first set a file mapping in your `docker-compose.yml` as an environment variable with the prefix `TEMPLATE_`:
```yaml
services:
  web:
    environment:
      TEMPLATE_DB_CONFIG: "database_config.php:./path/to/application/database_config.php"
```
In `_docker/web/templates/` define your configuration template file like this (in this case `database_config.php`):
```php
<?php
return [
    "database" => [
        "host" => '${DOMAIN}',
        "user" => '${DATABASE_USER_MAIN}',
        "password" => '${DATABASE_PASS_MAIN}',
        "database_name" => '${DATABASE_NAME_MAIN}'
    ],
    'wkhtmltopdfBinary' => '${WKHTMLTOPDF_BINARY}'
];
```
This also supports the bash default syntax with `:-` between variable name and default value:
```bash
${DOMAIN:-test.local}
```
If the environment variable `DOMAIN` is not set, this will default to `test.local`

The variables `DATABASE_USER_MAIN` and `DATABASE_PASS_MAIN` should be set in the `public.env`.
If you have more databases set these variables with a different suffix than `_MAIN`:
```dotenv
DATABASE_USER_MAIN="some_user"
DATABASE_PASS_MAIN="s3cr3tP4ssw0rd"
DATABASE_USER_SOMEOTHERSUFFIX="another_user"
DATABASE_PASS_SOMEOTHERSUFFIX="sauce"
```

In this case the literal environment variables in the file `_docker/web/templates/database_config.php` will be replaced 
with the corresponding environment value and then the file will be copied to `./path/to/application/database_config.php`.

The resulting file `./path/to/application/database_config.php` can be for example:
```php
<?php
return [
    "database" => [
        "host" => 'test.docker',
        "user" => 'some_user',
        "password" => 's3cr3tP4ssw0rd',
        "database_name" => 'some_db_name' 
    ],
    "wkhtmltopdfBinary" => '/usr/bin/wkhtmltopdf'
];
```

### 5. Install Composer
Composer is installed per default in it's lates version, and it runs `composer install` at startup if you set the path where it is executed with the following environment variable in your `docker-compose.yml`:
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

If you need another composer version installed (for example `1.x`) you can change this in the `Dockerfile` under `_docker/web/`:
```dockerfile
# install composer
RUN install-php-extensions @composer-1 && apt-get update && apt-get install -y unzip git
```
More info on this on https://github.com/mlocati/docker-php-extension-installer#installing-composer


### 6. Run `npm install` at startup
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


### 7. Install wkhtmltopdf
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

The binary path is stored in the environment variable `WKHTMLTOPDF_BINARY` available in the `web` container


### 8. Match your server setup
With Docker you want to match the environment of the server where the application will run later as close as possible.
This helps prevent weird errors and bugs that only occur on the live system or only on your development system.

Here are some additional tips to prevent them in the first place:
1. 

## Troubleshoot
#### bash into container:
To troubleshoot anything inside a container, go into the container with:
```shell
docker exec -it <container-name> /bin/bash
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
* [x] automate config files more - "template"-language, that dynamically replaces ${VARIABLES} of config files and maps them with volumes
* [x] install grunt into container
* [x] error when database name has - in name
* [x] 3307 as default port
* [x] replace-templates.sh: support for default values (syntax: `${WEB_PORT:-80}`)
* [x] bti-brandschutz: Fehler beim Anmelden: funktioniert nicht für bti-brandschutz.docker domain (Problem nur im Chrome: gefixt mit Cookies UND Websitedaten löschen: chrome://settings/siteData?searchSubpage=.docker)
* [x] test WKHTMLTOPDF in application
* [ ] better automation with xdebug path mapping (on a CakePHP project)
* [ ] automate LOOPBACK_IP?
* [ ] Dockerization Tips: add php.ini as configured on live server, correct PHP version as on server, composer.lock used on server, to install exactly those versions, correct composer version, install all required php extensions
* [ ] catch Emails like in devilbox?
* [ ] enable http2 on apache server?: https://http2.pro/doc/Apache (php-fpm)
* [ ] dockerize IFAA (Genesis World, ERP, Shop)
