#!/bin/bash
#
# Description
#
# This script connects to a given server via RPC, discovers it's SID and then enumerate the  machine / domain users via user SID bruteforce.
#
# This script relies on 'rpcclient' binary. Make sure to install 'smbclient' package on you Linux distro.
#
# This piece of code is intended for educational purposes only. I'm not responsible for it's misuse.
#
# Usage:
# ./rpc_brute_enum_users.sh -s 192.168.0.15 -u user -p 'P@ssw0rd'
#
# Autor: Daniel Zaia Manzano <sh11td0wn@gmail.com>
#

MSG_HELP="
 Usage:

 ./rpc_brute_enum_users.sh -s 192.168.0.15 -u user -p 'P@ssw0rd'

 -s, --server SERVER_IP		Specify server's IP address
 -u, --user USERNAME		Specify username
 -p, --password PASSWORD	Specify user's password

 * All of the above options are required
"

MSG_INVALID_OPTION="
 Invalid option!
"

if [ $1 -z ]
then
	echo "$MSG_HELP"
	exit 0
fi

# Options handling
while test -n "$1"
do
	case "$1" in
		-s | --server)
			SERVER_IP=$2
			shift
		;;
		-u | --user)
			USER=$2
			shift
		;;
		-p | --password)
			PASS=$2
			shift
		;;
		*)
			echo "$MSG_INVALID_OPTION"
			exit 1
		;;
	esac
	shift
done



DOMAIN_SID=$(rpcclient -U ${USER}%${PASS} ${SERVER_IP} -c "lookupnames administrator" | grep -v "password:" | cut -d" " -f 2 | cut -d"-" -f 1-7)

SIDS=""
for num in $(seq 500 2000)
do
	SIDS="${SIDS} ${DOMAIN_SID}-${num}"
done
#for num in $(seq 1000 1100)
#do
#	SIDS="${SIDS} ${DOMAIN_SID}-${num}"
#done

rpcclient -U ${USER}%${PASS} ${SERVER_IP} -c "lookupsids ${SIDS}" | grep -v '*unknown*'
