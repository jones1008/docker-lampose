# alpine image is a lot smaller than official mariadb image
FROM jbergstroem/mariadb-alpine:10.4.17

# replace posix shell with better bash shell:
RUN apk update && apk add bash
RUN mv /bin/sh /bin/sh.old && ln -s /bin/bash /bin/sh

# add unbuffered progress bar tool to have feedback at initial .sql files import
RUN apk update && apk add pv && apk add coreutils