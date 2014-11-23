#!/bin/sh

# usage: $0 iTunesConnectAccount(email) SKU
iTMSTransporter="$(xcode-select -p)/../Applications/Application Loader.app/Contents/MacOS/itms/bin/iTMSTransporter"
"$iTMSTransporter" -m upload -u $1 -f $2.itmsp
