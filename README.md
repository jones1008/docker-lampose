# Docker Setup

## <a id="notes"></a> Notes:
### Note 1:
If you make any changes to one of following files:
- `./docker-compose.yml`
- `./docker-compose.override.yml`

make sure to tear down the related docker containers like so:
```shell
docker-compose down -v
```

### <a id="note2"></a> Note 2:
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
### 1. Create `docker-compose.override.yml`
- copy `docker-compose.override.sample.yml` to `docker-compose.override.yml`

### 2. Database setup
- In the `docker-compose.override.yml` set the following evironment parameters:
    - `MYSQL_ROOT_PASSWORD`
    - `MYSQL_DATABASE`
- To import a database at **initial** docker startup move a `.sql` file to `./_docker/mariadb/`
    - This will execute the `.sql` file into the database you specified with `MYSQL_DATABASE` on **initial(!)** docker startup

### 3. PHP setup
- To specify the **PHP version** change the `FROM` command in `./_docker/php-apache/Dockerfile`
    - e.g. for PHP version 5.6:
```dockerfile
FROM php:5.6-apache
```
- After that make sure to build this container again (see [Note 2 above](#note2))
#### PHP Extensions:
- To install and enable **PHP extensions** add them to `./_docker/php-apache/Dockerfile`.
    - e.g. add and enable the PHP `mysql` extension like so:
```dockerfile
RUN docker-php-ext-install mysql && \
    docker-php-ext-enable mysql
```
#### xdebug:
- To enable xdebug set `xdebug.remote_enable` in `./_docker/php-apache/additional-inis/xdebug.ini` like so:
```
xdebug.remote_enable=1
```
- To edit any other xdebug configuration parameter add them within this `.ini` file
- The correct xdebug version should be installed with the `_docker/php-apache/install-xdebug.sh` script with the first docker build.
  
#### Config
- To edit any `php.ini` config, just add another `.ini` file to `_docker/php-apache/additional-inis/`

### 3. Connect to database
- To connect your **application** to the database use the following credentials:
  - host: name of the MySQL docker container (`mariadb`)
  - user: `root`
  - password: specified with `MYSQL_ROOT_PASSWORD` in `docker-compose.override.yml`
- You can connect to the database from any client outside of docker (for example [DBeaver](https://dbeaver.io/)) on: 
  - host: `localhost` 
  - port: can be configured in `docker-compose.override.sample.yml` (default `3307`)

### 4. Open Application
- To open the application frontend at root (`./`) open `localhost:<configured_port` in your browser. 
  - You can configure the port in `docker-compose.override.yml` (default `8080`) 

### 5. install wkhtmltopdf
- If you want to install [wkhtmltopdf](https://wkhtmltopdf.org) as a depencency in the php-apache container add the following to your `docker-compose.override.yml`:
```yaml
services:
  #...
  php-apache:
    build:
      args:
        WKHTMLTOPDF: "true"
```
- After that you have to **rebuild the container** (see [Note 2](#note2))
- Then the binary from wkhtmltopdf is available in the container under `/usr/local/bin/wkhtmltopdf`, so set this path in your application settings

## Troubleshoot

- To troubleshoot anything inside a container, go into the container with:
```shell
docker exec -it <container-name> /bin/bash
```
- For other problems read the [Notes](#notes) above

## Roadmap
* [ ] initial composer install execution within docker container