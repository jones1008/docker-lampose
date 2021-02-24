: # This is a special script which intermixes both sh and cmd code.
: # It is written this way because it is used in system() shell-outs directly in otherwise portable code.
: # See https://stackoverflow.com/questions/17510688 for details.

:; echo "trying to bash into web container..." && docker-compose exec web /bin/bash; exit
@echo off
echo trying to bash into web container...
docker-compose exec web /bin/bash