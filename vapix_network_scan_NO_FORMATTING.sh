#!/bin/bash

source common_utilities.sh

VAPIX_ENDPOINT="/axis-cgi/jpg/image.cgi"
PARAM_ENDPOINT="/axis-cgi/admin/param.cgi?action=list&group=Brand"
VAPIX_PROPERTIES="/axis-cgi/param.cgi?action=list&group=Properties"

clear
read -p "Please enter the network prefix. (e.g., 192.168.0): " SUBNET

START=11
END=255

USERNAME="root"
PASSWORD="admin51"

# Timeout in seconds
TIMEOUT=.1

printf "%-15s %-20s %-15s %-15s\n" "IP ADDRESS" "CAMERA MODEL" "MAC ADDRESS" "FIRMWARE VERSION" # Header
for i in $(seq $START $END); do
    IP="$SUBNET.$i"
    RESPONSE_CODE=$(curl -s --connect-timeout $TIMEOUT -o /dev/null -w "%{http_code}" -u "$USERNAME:$PASSWORD" "http://$IP$VAPIX_ENDPOINT")

    # Process only if the response code is 200
    if [ "$RESPONSE_CODE" == "200" ]; then

        # Fetching camera details
        CAMERA_DETAILS=$(curl -s --connect-timeout $TIMEOUT -u "$USERNAME:$PASSWORD" "http://$IP$PARAM_ENDPOINT")

        # Extracting name and model from the response
        CAMERA_NAME=$(echo "$CAMERA_DETAILS" | grep "ProdShortName" | cut -d"=" -f2)

        # Fetching camera MAC
        CAMERA_PROPERTIES=$(curl -s --connect-timeout $TIMEOUT -u "$USERNAME:$PASSWORD" "http://$IP$VAPIX_PROPERTIES")
        CAMERA_MAC=$(echo "$CAMERA_PROPERTIES" | grep "root.Properties.System.SerialNumber" | cut -d"=" -f2)
        CAMERA_FIRMWARE=$(echo "$CAMERA_PROPERTIES" | grep "root.Properties.Firmware.Version" | cut -d"=" -f2)

        printf "%-15s %-20s %-15s %-15s\n" "$IP" "$CAMERA_NAME" "$CAMERA_MAC" "$CAMERA_FIRMWARE"
    fi
done
