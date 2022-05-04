#!/bin/zsh

# Report the Crowdstrike installed state

app="/Applications/Falcon.app/Contents/Resources/falconctl"

if [ ! -f "$app" ];
then
	echo "<result>Not Installed</result>"
else
	test=$( /Applications/Falcon.app/Contents/Resources/falconctl stats | grep -i "State: " | awk '{ print $2 }' 2>/dev/null )

  if [ "$test" = "connected" ];
  then
	  echo "<result>$test</result>"
  else
	  echo "<result>error</result>"
  fi
fi
