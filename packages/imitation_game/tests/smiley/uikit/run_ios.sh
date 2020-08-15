#!/bin/sh
# TODO: What about customizing the DEVELOPMENT_TEAM?
set -e
cd $( dirname "${BASH_SOURCE[0]}" )
cd smiley
xcodebuild -scheme smiley -configuration Release -project smiley.xcodeproj -archivePath ./smiley.xcarchive archive
xcodebuild -exportArchive -archivePath ./smiley.xcarchive/ -exportPath . -exportOptionsPlist exportOptions.plist -allowProvisioningUpdates
ios-deploy --justlaunch --bundle ./smiley.xcarchive/Products/Applications/smiley.app
