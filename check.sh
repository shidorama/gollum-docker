#!/usr/bin/env bash
# Let's check config overall sanity
LINES_CONFIGURED=$(egrep -c  ^[a-zA-Z_]+=[\'\"]{1}[^\'\"]+[\'\"]{1}$ /wiki/tmp/config.env)
LINES_NEEDED=5
EXITCODE=0
PUBLIC_KEY=/root/.ssh/id_rsa.pub
PRIVATE_KEY=/root/.ssh/id_rsa

echoerr() { echo "$@" 1>&2; }
genError() { let "EXITCODE = ${EXITCODE} + 3"; }

if [[ ${LINES_CONFIGURED} != ${LINES_NEEDED} ]]
then
    echoerr 'config env should be populated'
    genError
else
    echo 'config seems fine'
fi

if [ -f ${PUBLIC_KEY} ] || [ -f ${PRIVATE_KEY} ]
then
echo "keys exists. Thats a relief"
    if [[ $(stat -c%s ${PUBLIC_KEY}) -eq 0 || $(stat -c%s ${PRIVATE_KEY}) -eq 0 ]]
    then
        genError
        echoerr 'Public or private key size are too small'
    fi
else
    genError
    echoerr 'key file(s) does not exist'
fi
exit ${EXITCODE}
