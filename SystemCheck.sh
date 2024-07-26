#!/bin/bash

# Ping Cloudflare for 30 seconds
ping -c 10 -W 3 cloudflare.com &> /dev/null

# Check if ping was successful
if [[ $? -eq 0 ]]; then
  # Cloudflare is reachable, send Gotify notification
  curl -X POST "https://gotify.saavagebueno.com/message?token=XXXXXXXXXXXXXXXX" -F "title=XXXXXXXXX" -F "message=OK"
else
  # Cloudflare is unreachable, attempt to renew DHCP lease
  echo "Cloudflare unreachable, renewing DHCP lease..."
  dhclient
  dhclient -r
  
  # Ping Cloudflare again
  ping -c 10 -W 3 cloudflare.com &> /dev/null
  
  # Check if ping was successful
  if [[ $? -eq 0 ]]; then
    # Cloudflare is now reachable, send Gotify notification
    echo "Cloudflare is now reachable."
    curl -X POST "https://gotify.saavagebueno.com/message?token=XXXXXXXXXXXXXXXX" -F "title=XXXXXXXXX" -F "message=Ping Succeded! System OK"
  else
    # Cloudflare is still unreachable, reboot the system
    echo "Cloudflare is still unreachable, rebooting system..."
    reboot now
  fi
fi