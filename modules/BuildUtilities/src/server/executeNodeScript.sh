#!/bin/sh
#The standard for executing node scripts is " #!/usr/bin/env node" but in some cases "/usr/bin/env" does not exist (apache SSLPassPhraseDialog)
#This is a script that will cycle through known node install locations and execute a script
for node in /usr/local/bin/node /usr/bin/node
do
    if [ -x "$node" ]
    then
        "$node" $1
        break
    fi
done