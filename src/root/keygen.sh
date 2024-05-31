#! /bin/bash

# selection menu
echo "Please select your key type to generate"
printf "1.) ecdsa\n2.) rsa\n3.) ed25519\n4.) dsa\n[default ecdsa]:"
read opt
case $opt in
    1|"ecdsa") TYPE="ecdsa" BITS="-b 521";;
    2|"rsa") TYPE="rsa";;
    3|"ed25519") TYPE="ed25519";;
    4|"dsa") TYPE="dsa";;
    *) echo "blank or unknown option choosing ecdsa" && TYPE="ecdsa" BITS="-b 521";;
esac

# rsa bit selection
if [[ "$TYPE" == "rsa" ]]; then
    echo "Please select RSA bits"
    printf "1.) 4096\n2.) 2048\n3.) 1024\n[default 4096]:"
    read opt
    case $opt in
        1|4096) BITS="-b 4096";;
        2|2048) BITS="-b 2048";;
        3|1024) BITS="-b 1024";;
        *) echo "blank or unknown option choosing 4096" && BITS="-b 4096";;
    esac
fi

# key generation
echo "YOUR KEY/PUBFILE IS BELOW PLEASE SAVE THIS DATA AS WE WILL NOT"
echo /tmp/stderr{,.pub} | xargs -n 1 ln -sf /dev/stderr && yes | ssh-keygen -t ${TYPE} ${BITS} -N '' -q /tmp/stderr > /dev/null
