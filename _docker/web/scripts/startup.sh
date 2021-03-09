#!/bin/bash

wd=$(pwd)

if [ -z "$PROJECT_NAME" ]; then
  echo "[ERROR]: startup.sh: required environment variable PROJECT_NAME not set"
  exit 1
fi

if [ -z "$DOMAIN" ]; then
  echo "[ERROR]: startup.sh: required environment variable DOMAIN not set"
  exit 1
fi

# call build-config.sh
if ! ./_docker/web/scripts/replace-templates.sh; then
  exit 1
fi

# call set-hostname.sh
if ! ./_docker/web/scripts/set-hostname.sh; then
  exit 1
fi

# call git-submodule-update.sh
if ! ./_docker/web/scripts/git-submodule-update.sh; then
  exit 1
fi

# call git-submodule-update.sh
if ! ./_docker/web/scripts/clone-into.sh; then
  exit 1
fi

# call composer-npm-install.sh
if ! ./_docker/web/scripts/composer-npm-install.sh; then
  exit 1
fi

# call catch-mail.sh
if [ -n "$CATCH_MAIL" ] && [ "$CATCH_MAIL" = "true" ]; then
    if ! ./_docker/web/scripts/setup-catch-mail.sh; then
      exit 1
    fi

    if [ -z "$CATCH_MAIL_PORT" ]; then
        CATCH_MAIL_PORT=8025
    fi
    echo "All catched mails available at http://$DOMAIN:$CATCH_MAIL_PORT"
fi

cd "$wd" || exit 1

# start application
sleep 1 && \
httpDomain="http://$DOMAIN" && \
httpsDomain="https://$DOMAIN" && \
if [ -n "$WEB_PORT" ]; then \
  httpDomain="$httpDomain:$WEB_PORT"; \
fi && \
if [ -n "$WEB_PORT_SSL" ]; then \
  httpsDomain="$httpsDomain:$WEB_PORT_SSL"; \
fi && \
echo "application started with self-signed certificate at $httpsDomain and without at $httpDomain" && \
if [ -n "$EXTERNAL_IP" ]; then \
  externalDomain="http://$EXTERNAL_IP"; \
  if [ -n "$WEB_PORT" ]; then \
    externalDomain="$externalDomain:$WEB_PORT"; \
  fi && \
  echo "application started at $externalDomain"; \
fi & \

exec 'apache2-foreground'