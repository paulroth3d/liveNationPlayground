#!/bin/bash

perl -0777 -pi -e 's/<userPermissions>[^<]+<enabled>[^<]+<\/enabled>[^<]+<name>SubscribeToLightningReports<\/name>[^<]+<\/userPermissions>[^<]+//gi' force/src/profiles/*.profile
perl -0777 -pi -e 's/(<values>[^<]+<fullName>[^<]+<\/fullName>[^<]+<default>[^<]+<\/default>[^<]+<\/values>)[^<]+\1/$1/gi' force/src/objects/*.object