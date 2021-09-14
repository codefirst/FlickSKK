#!/bin/sh

# Set the -e flag to stop running the script in case a command returns
# a non-zero exit code.
set -e
set -x

gem install --user-install bundler
bundle config set --local path .bundle
bundle install

if [[ ! -e .cocoapods_appgroup ]]; then
    bundle exec pod app-group org.codefirst.FlickSKK
fi

bundle exec pod env
bundle exec pod install
