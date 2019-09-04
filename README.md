# rpc_brute_enum_users
This script connects to a given server via RPC, discovers it's SID and then enumerate the machine / domain users via user SID bruteforce.


    Description:

    This script connects to a given server via RPC,
    discover it's SID and then enumerate users, groups and machine IDs via SID bruteforce.

    Usage:

    ./rpc_brute_enum_users.sh -s 192.168.0.15 -u user -p 'P@ssw0rd'

    Options:
 
    -s, --server SERVER_IP		Specify server's IP address [REQUIRED]
    -u, --user USERNAME		Specify username 	    [REQUIRED]
    -p, --password PASSWORD         Specify user's password     [REQUIRED]

    -d, --domain			Specify server's domain (default: WORKGROUP)
    -o, --only-users		Display only accounts usernames. Useful for creating user wordlists.



                 *** Do NOT use this for illegal or malicious use ***                     
            By running this, YOU are using this program at YOUR OWN RISK.                 
        This software is provided "as is", WITHOUT ANY guarantees OR warranty.            
