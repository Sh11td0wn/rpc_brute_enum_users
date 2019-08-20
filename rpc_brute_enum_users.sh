#!/bin/bash
#
# Description
#
# This script connects to a given server via RPC,
# discover it's SID and then enumerate users, groups and machine IDs via SID bruteforce.
#
# This script relies on 'rpcclient' binary. Make sure to install 'smbclient' package on you Linux distro.
# This script relies on 'openssl' binary. Make sure to install 'openssl' package on you Linux distro.
#
#                     *** Do NOT use this for illegal or malicious use ***                     #
#                By running this, YOU are using this program at YOUR OWN RISK.                 #
#            This software is provided "as is", WITHOUT ANY guarantees OR warranty.  
#

# Usage:
# ./rpc_brute_enum_users.sh -s 192.168.0.15 -u user -p 'P@ssw0rd'
#
# Version: 1.2
#
# Autor: Sh11td0wn (Github)
#

MSG_HELP="
 Description:

 This script connects to a given server via RPC,
 discover it's SID and then enumerate users, groups and machine IDs via SID bruteforce.

 Usage:

 ./rpc_brute_enum_users.sh -s 192.168.0.15 -u user -p 'P@ssw0rd'

 Options:
 
 -s, --server SERVER_IP		Specify server's IP address [REQUIRED]
 -u, --user USERNAME		Specify username 	    [REQUIRED]

 -p, --password PASSWORD	Specify user's password (If ommited, the user's password will be asked interactively)
 -d, --domain			Specify server's domain (default: WORKGROUP)
 -o, --only-users		Display only accounts usernames. Useful for creating user wordlists.
"

if [ "$*" == "" ]
then
	echo "$MSG_HELP"
	exit 0
fi

# Default options
SERVER_IP=0
USER=0
DOMAIN="WORKGROUP"
PASS_FROM_CMD=0
ONLY_USERS=0

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
		-o | --only-users)
			ONLY_USERS=1
		;;
		*)
			echo "Invalid option: $1"
			exit 1
		;;
	esac
	shift
done

# Flags handling

# Validation of required options
if [ ${SERVER_IP} == 0 ] || [ ${USER} == 0 ]
then
	echo "Options --server and --user are required!"
	exit 1
fi

# Check if password was provided on command line. If not, script asks interactively.
if [ ${PASS_FROM_CMD} -eq 0 ]
then
	read -s -p "Enter ${DOMAIN}\\${USER} password: " PASS
	echo
fi

# Generate NT hash from password (Solves special chars trouble on calling rpcclient)
PASS_NT_HASH=$(echo -n ${PASS} | iconv -t utf16le | openssl md4 | cut -d" " -f 2)

# Main processing

# Workgroup / Domain SID discovery
DOMAIN_SID=$(rpcclient -U ${USER}%${PASS_NT_HASH} --pw-nt-hash ${SERVER_IP} -W ${DOMAIN} -c "lookupnames administrator" | grep -v "password:" | cut -d" " -f 2 | cut -d"-" -f 1-7)

# SID's list creation
SIDS=""
for num in $(seq 500 2000)
do
	SIDS="${SIDS} ${DOMAIN_SID}-${num}"
done

# User's enumeration main command
RESULT="rpcclient -U ${USER}%${PASS_NT_HASH} --pw-nt-hash ${SERVER_IP} -W ${DOMAIN} -c 'lookupsids ${SIDS}' | grep -v '*unknown*' | grep -v '00000'"

# Validation of --only-users option
if [ ${ONLY_USERS} -eq 1 ]
then
	RESULT="${RESULT} | grep '(1)' | grep -v '\\$' | cut -d'\' -f2 | cut -d' ' -f 1 "
fi

bash -c "${RESULT}"
