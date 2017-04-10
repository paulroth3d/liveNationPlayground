#!/bin/bash

##Sample file explaining how to deploy from shellscript.

##Although ant is a OS agnostic alternative to Shellscript/bat
##it is sometimes necessary to run externally




## name of the file list to be deployed (no extension)
#fileList=home

## -D sets a property (similar to setting the property in build.properties/build.environment)
## -DoverrideContinue ignores any prompts for confirmation
## -DfileList specifies the fileList that should be used

#ant deployFromList -DoverrideContinue=y -DfileList=${fileList}

