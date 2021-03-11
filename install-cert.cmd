: # This is a special script which intermixes both sh and cmd code.
: # It is written this way because it is used in system() shell-outs directly in otherwise portable code.
: # See https://stackoverflow.com/questions/17510688 for details.

:<<BATCH
    @echo off

    set dockerweb=_docker\web
    set mkcert=%dockerweb%\install-cert\mkcert-v1.4.3-windows-amd64.exe
    set certFileFolder=%dockerweb%\certs

    set domain=%1
    IF "%domain%"=="" (
        echo [ERROR] domain not specified!
        echo usage:  install-cert.cmd example.com
        exit /b
    )

    %mkcert% -install
    %mkcert% -cert-file %certFileFolder%\public.pem -key-file %certFileFolder%\private-key.pem %domain%

    echo [INFO]: For Firefox support: import certificate authority (CA) manually in Firefox with 'rootCA.pem' from following path
    %mkcert% -CAROOT
    echo For more instructions see README.md

    exit /b
BATCH


dockerweb="_docker/web"
mkcert="$dockerweb/install-cert/mkcert-v1.4.3-linux-amd64"
certFileFolder="$dockerweb/certs"

domain=$1
if [ -z "$domain" ]; then
    echo "[ERROR] domain not specified!"
    echo "usage:  install-cert.cmd example.com"
    exit
fi

"$mkcert" -install
"$mkcert" -cert-file "$certFileFolder/public.pem" -key-file "$certFileFolder/private-key.pem" "$domain"

echo "[INFO]: For Firefox support: import certificate authority (CA) manually in Firefox with 'rootCA.pem' from following path"
"$mkcert" -CAROOT
echo "For more instructions see README.md"