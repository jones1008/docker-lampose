: # This is a special script which intermixes both sh and cmd code.
: # It is written this way because it is used in system() shell-outs directly in otherwise portable code.
: # See https://stackoverflow.com/questions/17510688 for details.

:<<BATCH
    @echo off
    set name=%1
    set shell=%2
    IF "%name%"=="" (
        set name="web"
    )
    IF "%shell%"=="" (
        set shell="/bin/bash"
    )
    echo bashing into container %name% on %shell%...
    docker-compose exec %name% %shell%
    exit /b
BATCH

name=$1
shell=$2
if [ -z "$name" ]; then
    name=web
fi
if [ -z "$shell" ]; then
    shell=/bin/bash
fi
echo "bashing into container $name on $shell..."
docker-compose exec "$name" "$shell"