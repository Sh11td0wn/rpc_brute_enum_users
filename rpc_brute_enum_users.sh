#!/bin/bash
#
# Description
#
# This script connects to a given server via RPC,
# discovers it's SID and then enumerate the  machine / domain users via user SID bruteforce.
#
# This script relies on 'rpcclient' binary. Make sure to install 'smbclient' package on you Linux distro.
#
#                     *** Do NOT use this for illegal or malicious use ***                     #
#                By running this, YOU are using this program at YOUR OWN RISK.                 #
#            This software is provided "as is", WITHOUT ANY guarantees OR warranty.  
#

# Usage:
# ./rpc_brute_enum_users.sh -s 192.168.0.15 -u user -p 'P@ssw0rd'
#
# Autor: sh11td0wn (Github)
#

# TODO
#
# 
#

MSG_HELP="
 Usage:

 ./rpc_brute_enum_users.sh -s 192.168.0.15 -u user -p 'P@ssw0rd'

 Options:
 
 -s, --server SERVER_IP		Specify server's IP address
 -u, --user USERNAME		Specify username
 

 * All of the above options are required

 -p, --password PASSWORD	Specify user's password
  (If -p is ommited, the user's password will be asked interactively)
 -d, --domain			Specify the server's domain (default: WORKGROUP)

"

MSG_INVALID_OPTION="
 Invalid option!
"

if [ $1 -z ]
then
	echo "$MSG_HELP"
	exit 0
fi

# Default options
DOMAIN="WORKGROUP"
PASS_FROM_CMD=0

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
			PASS_FROM_CMD=1
			shift
		;;
		-d | --domain)
			DOMAIN=$2
			shift
		;;
		*)
			echo "$MSG_INVALID_OPTION"
			exit 1
		;;
	esac
	shift
done

# Flags handling

if [ ${PASS_FROM_CMD} -eq 0 ]
then
	read -s -p "Enter ${DOMAIN}\\${USER} password: " PASS
	echo
fi

# Main processing

# Workgroup / Domain SID discovery
DOMAIN_SID=$(rpcclient -U ${USER}%${PASS} ${SERVER_IP} -W ${DOMAIN} -c "lookupnames administrator" | grep -v "password:" | cut -d" " -f 2 | cut -d"-" -f 1-7)

# SID's list creation
SIDS=""
for num in $(seq 500 2000)
do
	SIDS="${SIDS} ${DOMAIN_SID}-${num}"
done

# User's enumeration main command
rpcclient -U ${USER}%${PASS} ${SERVER_IP} -W ${DOMAIN} -c "lookupsids ${SIDS}" | grep -v '*unknown*'
