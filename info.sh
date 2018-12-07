#!/bin/bash
#########################################################################################
#  Name:        Derek Van Vuuren
#  Date:        20181207
#  Version:     1.8.7
#  Description: info.sh is a script designed to aid in information gathering
#               it provide ping, nslookup, and whois capabilites
#               if your system does not have the prerequisite commands
#               it will install them for you as long as you specify the os
#               info.sh [IP Address/FQDN] [(a)rch, (d)ebian]
#########################################################################################
host=$1
os=$2
#checks for required commands on an arch based system
function dependarch
{
    if ! type "whois" &> /dev/null; then
        pacman -Sy whois
    fi
    if ! type "nslookup" &> /dev/null; then
        pacman -Sy bind-tools
    fi
    if ! type "ping" &> /dev/null; then
        pacman -Sy iputils
    fi
    menu
}
 #checks for required commands on a debian based system
function dependdeb
{
    if ! type "whois" &> /dev/null; then
        apt update && apt install whois
    fi
    if ! type "nslookup" &> /dev/null; then
        apt update && apt install dnsutils
    fi
    if ! type "ping" &> /dev/null; then
        apt update && apt install iputils-ping
    fi
    menu
}
# Displays the menu
function menu
{
     echo The current host is $host
    PS3='Please enter your choice: '
    options=("Ping Host" "Get Host IP" "Get Host Info" "Update Host" "Quit") 
    select opt in "${options[@]}"
    do
        case $opt in
            "Ping Host")
                echo "You chose Ping"
                check
                ;;
            "Get Host IP")
                echo "You chose to Get Host IP"
                ip
                ;;
            "Get Host Info")
                echo "you chose choice $REPLY which is $opt"
                info
                ;;
            "Update Host")
                echo "You chose to update the Host which is $host"
                update
                ;;
            "Quit")
                echo "Bye!!!!"
                exit;
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

}
#allows you to change the $host variable
function update
{
    clear
    echo ═════════════════════════════════════════════════════════
    echo
    echo "The old host is $host."
    echo "Enter a new Host ( IP or FQDN ):"
    echo
    echo ═════════════════════════════════════════════════════════
    read host
    clear
    menu
}
# pings the host two times
function check
{
    clear
    echo ═════════════════════════════════════════════════════════
    echo
    echo "Pinging $host"
    echo
    ping -c 2 -q $host|grep "packet loss"
    echo 
    echo ═════════════════════════════════════════════════════════
    menu
}
# uses nslookup to get the $host ipv4 and ipv6 info
function ip
{
    clear
    echo ═════════════════════════════════════════════════════════
    echo
    echo "looking up $host with nslookup"
    echo
    nslookup $host| grep "Address:"
    echo 
    echo ═════════════════════════════════════════════════════════
    menu
}
# uses whois to get Registrant contact information
function info
{
clear
    echo ═════════════════════════════════════════════════════════
    echo
    echo "getting whois info for $host"
    echo
    whois $host |grep "Registrant Name:"
    whois $host |grep "Registrant Phone:"
    whois $host |grep "Registrant Email:"
    echo 
    echo ═════════════════════════════════════════════════════════
    menu
}
# determines which operating system you chose
function dependchk
{
    if [ $os = "a" ]; then 
        dependarch
    elif [ $os = "d" ]; then 
        dependdeb
    else
        echo "You chose an incorrect option and are missing dependencies
         please specify your operating system (a)rch, (d)ebian: "
        read os
        dependchk
    fi
}
# Displays a manpage style help page
function help
{
    echo "╔═══════════════════════════════════════════════════════════════════════════╗
║ NAME                                                                      ║
║         info.sh - collects basic network info                             ║
║                                                                           ║
║ SYNOPSIS                                                                  ║
║         info.sh host [ad]                                                 ║
║                                                                           ║
║ DESCRIPTION                                                               ║
║         info.sh used ping, nslookup and whois to collect information      ║
║         about a given host                                                ║
║                                                                           ║
║ OPTIONS                                                                   ║
║         a      sets the operating system to arch                          ║
║                 *optional but required for built in updater               ║
║         d      sets the operating system to debian                        ║
║                 *optional but required for built in updater               ║
║                                                                           ║
║ EXAMPLE                                                                   ║
║        info.sh www.example.com d                                          ║
║                                                                           ║
║ Date:         20181206                                                    ║
║ Version:      1.8.7                                                       ║
║ Author:       Derek L. Van Vuuren                                         ║
║ E-mail:       derek.vanvuuren@gmail.com                                   ║
║ E-mail:       vanvuuren2823@student.cptc.edu                              ║
║ Github:       https://github.com/dawk42/info.sh/                          ║
╚═══════════════════════════════════════════════════════════════════════════╝"
}
# Determines which variables are set and makes a desicion what to do
function varcheck
{
    if test -z "$host"; then
        help
        exit   
    elif test -z "$os"; then
        echo "Choose option 4 to set a host"
        menu
    else
        dependchk
    fi
}

if [[ $EUID -ne 0 ]]; then
   echo "This script requires adminstrative privilages.
   Please run as root or an account with sudo." 
   exit 1
else
    varcheck
fi
