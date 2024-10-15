#!/bin/zsh

# Find any falconctl binary
falconctl=$( /usr/bin/find /Applications/Falcon.app -iname "falconctl" -type f -maxdepth 3 )

# If installed
if [ "$falconctl" ];
then
    # Test for status
    test=$( "$falconctl" stats CloudInfo | /usr/bin/awk '/Cloud Info | State/ {print $2}' )
    
    if [ "$test" = "connected" ];
    then
    	# Report working
        echo "<result>Connected</result>"
    else
    	# We should do something about this
    	echo "<result>DISCONNECTED</result>"
    fi
else
    # Not present. Report and exit.
    echo "<result>Not Installed</result>"
fi
