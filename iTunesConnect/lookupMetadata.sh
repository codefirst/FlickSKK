#!/bin/sh

# usage: $0 iTunesConnectAccount(email) SKU
iTMSTransporter="$(xcode-select -p)/../Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter"
"$iTMSTransporter" -m lookupMetadata -u $1 -vendor_id $2 -destination .
