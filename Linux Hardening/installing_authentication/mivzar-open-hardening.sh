#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: run as root!"
  exit 1
fi

arg="$1" 

if [[ -z "$arg" ]]; then
  #stop_usbguard
  #stop_nftables_firewall
  fapolicyd-enforce-stop
  :
elif [[ "$arg" == "-s" ]]; then
  #stop_usbguard
  #stop_nftables_firewall 
  fapolicyd-scan
  : 
else
  echo "The parameter must be either empty or -s!!"
  exit 1
fi

