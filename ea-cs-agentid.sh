#!/bin/zsh

# Report the Crowdstrike Agent ID of the client if the Crowdstrike Agent if installed
# Original EA: https://github.com/zoocoup/CrowdstikeEAsforJamfPro/blob/main/CrowdstrikeFalconv6AgentIDEA.sh

falconctl=$( /usr/bin/find /Applications -iname "falconctl" -type f -maxdepth 4 )

if [ "$falconctl" ];
then
  echo "<result>$( "$falconctl" stats | /usr/bin/awk '/agentID/ {print $2}' | /usr/bin/tr '[:upper:]' '[:lower:]' | /usr/bin/sed 's/\-//g' )</result>"
else
	echo "<result>Not Installed</result>"
fi
