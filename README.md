# Docker Setup

## Notes:
### Note 1:
If you make any changes to one of following files:
- `docker-compose.yml`

make sure to tear down the related docker containers like so:
```shell
docker-compose down -v
```

### Note 2:
If you make any changes to one of the following files:
- any `Dockerfile`

make sure to rebuild it without cache:
```shell
docker-compose build --no-cache
```
___
After that you can start it again with:
```shell
docker-compose up
```


## Configuration:
### 1. Create `.env` file
- copy `.env.sample` to `.env`


### 2. Set your project name
- Set your project name in the `.env` file like so:
```dotenv
COMPOSE_PROJECT_NAME=my-project
```
- This prevents container name collisions in the future.


### 3. Database
#### Config:
- Set your password and your database name in the `.env` file like so:
```dotenv
MYSQL_ROOT_PASSWORD=password
MYSQL_DATABASE=database_name
```
#### Import at initial startup:
- To import a database at **initial** docker startup move a `.sql` file to `./_docker/mariadb/`
- This will only be executed at first container startup. 
  - Tear down the containers to start fresh and import your `.sql` file (see Note 1 above)


### 3. PHP setup
- To specify the **PHP version** change the `FROM` command in `./_docker/apache-php/Dockerfile`
    - e.g. for PHP version 5.6:
```dockerfile
FROM php:5.6-apache
```
- After that make sure to build this container again (see Note 2 above)
#### PHP Extensions:
- To install and enable **PHP extensions** add them to `./_docker/apache-php/Dockerfile`.
    - e.g. add and enable the PHP `mysql` extension like so:
```dockerfile
RUN docker-php-ext-install mysql && \
    docker-php-ext-enable mysql
```
#### xdebug:
- To enable xdebug set `xdebug.remote_enable` in `./_docker/apache-php/additional-inis/xdebug.ini` like so:
```
xdebug.remote_enable=1
```
- To edit any other xdebug configuration parameter add them within this `.ini` file
- The correct xdebug version should be installed with the `_docker/apache-php/install-xdebug.sh` script with the first docker build.
  
#### Config
- To edit any `php.ini` config, just add another `.ini` file to `_docker/apache-php/additional-inis/`

### 4. Webserver Setup
- If you need to set the root directory of your web application other than `./` set it in `_docker/apache-php/sites-available/000-default.conf` like so:
```apacheconf
# ...
DocumentRoot /var/www/html/some-sub-directory
```
- After that a **restart of docker-compose** is required.

### 5. install wkhtmltopdf
- If you want to install [wkhtmltopdf](https://wkhtmltopdf.org) as a depencency in the apache-php container add the following to your `.env` file:
```dotenv
INSTALL_WKHTMLTOPDF=true
```
- After that you have to **rebuild the container** (see Note 2 above)
- Then the binary from wkhtmltopdf is available in the container under `/usr/local/bin/wkhtmltopdf`, so set this path in your application settings


### 6. Start your containers
- After configuration you can start your containers with:
```shell
docker-compose up
```


### 7. Connect to database
- To connect your **application** to the database use the following credentials:
  - host: name of MySQL docker container `mariadb-<COMPOSE_PROJECT_NAME>`
    - `COMPOSE_PROJECT_NAME` defined in `.env` file
  - user: `root`
  - password: specified with `MYSQL_ROOT_PASSWORD` in `.env` file
- You can connect to the database from any client outside of docker (for example [DBeaver](https://dbeaver.io/)) on: 
  - host: `localhost` 
  - port: can be configured in `.env` file like so (default `3307`):
```dotenv
MARIADB_PORT=3307
```


### 8. Open Application
- To open the application frontend at root (`./`) open `localhost:<port>` in your browser. 
  - You can configure the port in `.env` file like so (default `8080`):
```dotenv
APACHE_PORT=8080
```


## Troubleshoot
#### bash into container:
- To troubleshoot anything inside a container, go into the container with:
```shell
docker exec -it <container-name> /bin/bash
```

## Roadmap
* [ ] initial composer install execution within docker container
* [ ] use of docker alpine packages to create smaller container
* [x] set webroot of web application