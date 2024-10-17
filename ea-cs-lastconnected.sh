#!/bin/zsh

# Report the last Crowdstrike connection to the cloud
# Original EA: https://github.com/zoocoup/CrowdstikeEAsforJamfPro/blob/main/CrowdstrikeFalconv6LastEstablishedEA.sh
# With fixes inspired by @sdagley and @rayjd on Mac Admins Slack

falconctl=$( /usr/bin/find /Applications/Falcon.app -iname "falconctl" -type f -maxdepth 3 )

if [ "$falconctl" ];
then
    test=$( "$falconctl" stats Communications | /usr/bin/awk '/Cloud Activity | Established At/ {print $3,$4,$5,$7; exit;}' );

    [ -z "$test" ] && { test=$( "$falconctl" stats Communications | /usr/bin/awk '/Cloud Activity | Last Established At/ {print $4,$5,$6,$8; exit;}' ) }
    
    if [ ! -z "$test" ];
    then
        echo "<result>$( /bin/date -j -f "%b %d, %Y %H:%M:%S" "$test" "+%Y-%m-%d %H:%M:%S" )</result>"
    else
    	echo "<result>1970-01-01 09:00:00</result>"
    fi
else
    echo "<result>1970-01-01 09:00:00</result>"
fi
