#!/usr/bin/env bash
# Let's check config overall sanity
LINES_CONFIGURED=$(egrep -c  ^[a-zA-Z_]+=[\'\"]{1}[^\'\"]+[\'\"]{1}$ /wiki/tmp/config.env)
LINES_NEEDED=6
EXITCODE=0
ROOTDIR="/wiki/certs"

echoerr() { echo "$@" 1>&2; }
genError() { let "EXITCODE = ${EXITCODE} + 3"; }

# Checking config sanity
if [[ ${LINES_CONFIGURED} != ${LINES_NEEDED} ]]
then
    echoerr 'config env should be populated'
    genError
else
    echo 'config seems fine'
fi

# checking ssh config sanity
if [ -f ${SSH_PUBLIC_KEY} ] || [ -f ${SSH_PRIVATE_KEY} ]
then
echo "keys exists. Thats a relief"
    if [[ $(stat -c%s ${SSH_PUBLIC_KEY}) -eq 0 || $(stat -c%s ${SSH_PRIVATE_KEY}) -eq 0 ]]
    then
        genError
        echoerr 'Public or private key size are too small'
    else
        echo "setting permissions. Just in case...."
        chmod ou-rwx ${SSH_PUBLIC_KEY} ${SSH_PRIVATE_KEY}
        SSH_PUBLIC_PR=$(ssh-keygen -y -f ${SSH_PRIVATE_KEY} | cut -d ' ' -f 1,2)
        SSH_PUBLIC_PU=$(cat ${SSH_PUBLIC_KEY} | cut -d ' ' -f 1,2)
        if [ ${SSH_PUBLIC_PR} -ne ${SSH_PUBLIC_PU} ]
        then
            genError
            echoerr 'Public and private key does not match'
        fi
    fi
else
    echo 'No keys detected. Let me generate them for you....'
    ssh-keygen -f ${ROOTDIR}/id_rsa -N ''
    if [ $? -ne 0 ]
    then
        genError
        echoerr 'SSH key generation attempt ended up in error'
    fi
    echo 'public ssh key:'
    cat ${ROOTDIR}/id_rsa.pub
    echo 'Waiting for 10 seconds'
    sleep 10
fi

if [ ${EXITCODE} -eq 0 ]
then
    echo 'Creating symlinkls'
    ln -s ${ROOTDIR}/id_rsa /root/.ssh/id_rsa
    ln -s ${ROOTDIR}/id_rsa.pub /root/.ssh/id_rsa.pub
    echo 'Setting SSH keys permissions'
    chmod go-rwx /root/.ssh/id_rsa*
fi


exit ${EXITCODE}
