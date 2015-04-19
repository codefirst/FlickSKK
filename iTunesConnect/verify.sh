#!/bin/sh

# usage: $0 iTunesConnectAccount(email) SKU
iTMSTransporter="$(xcode-select -p)/../Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter"
"$iTMSTransporter" -m verify -u $1 -f $2.itmsp
