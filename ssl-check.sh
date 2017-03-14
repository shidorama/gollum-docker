#!/usr/bin/env bash
EXITCODE=0
SSL_ROOTDIR=/etc/letsencrypt/live/${DOMAIN}
SSL_CERTIFICATE=${SSL_ROOTDIR}/fullchain.pem
SSL_PRIVATE_KEY=${SSL_ROOTDIR}/privkey.pem

echoerr() { echo "$@" 1>&2; }
genError() { let "EXITCODE = ${EXITCODE} + 3"; }

#ssl
if [ -f ${SSL_CERTIFICATE} ] || [ -f ${SSL_PRIVATE_KEY} ]
then
    # check for certificate `sanity`
    # Is it readable at all?
    SSL_CERT_READ_RESULT=$(openssl x509 -noout -in ${SSL_CERTIFICATE} > /dev/null 2>&1 || echo $?)
    SSL_PK_READ_RESULT=$(openssl rsa -noout -in ${SSL_PRIVATE_KEY} > /dev/null 2>&1 || echo $?)
    if [ ${SSL_CERT_READ_RESULT} -eq 0 ] && [ ${SSL_PK_READ_RESULT} -eq 0 ]
    then
        # Are PK and CERT match each other
        SSL_CERT_MD5=$(openssl x509 -noout -modulus -in ${SSL_CERTIFICATE} | openssl md5)
        SSL_PK_MD5=$(openssl rsa -noout -modulus -in ${SSL_PRIVATE_KEY} | openssl md5)
        if [ ${SSL_PK_MD5} -eq ${SSL_CERT_MD5} ]
        then
            # md5 match -> certs match
            PRESUMED_DOMAIN=$(openssl x509 -in ${SSL_CERTIFICATE} -subject -noout | cut -d= -f3)
            if [ ${PRESUMED_DOMAIN} -ne ${DOMAIN} ]
            then
            genError
            echoerr "SSL key domain doesn't match with one that's in config: SSL: ${PRESUMED_DOMAIN}, CONFIG: ${DOMAIN}"
            fi

        else
            genError
            echoerr 'SSL keys are not matching'
        fi

    else
        genError
        echoerr 'SSL certificate(s) are not in the correct format/unreadable'
    fi
else
    EXITCODE=2
    echoerr 'SSL key file(s) does not exist'
fi
if [ ${EXITCODE} -gt 2 ]
then
    exit $EXITCODE
fi

if [ ${EXITCODE} -eq 2 ]
then
    service nginx start
    certbot-auto -n certonly -a webroot --webroot-path=/wiki/webssl -d ${DOMAIN} --agree-tos --email ${SSL_EMAIL}

fi
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
rm /etc/nginx/sites-available/gollum.conf
mv /wiki/tmp/gollum-ssl.conf /etc/nginx/sites-available/gollum.conf
sed -ie "s/<placeholder>/${DOMAIN}/g" /etc/nginx/sites-available/gollum.conf
service nginx restart