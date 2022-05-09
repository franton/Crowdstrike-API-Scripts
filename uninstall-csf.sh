#!/bin/zsh

# Script to uninstall Crowdstrike
# richard@richard-purves.com - 05/04/2022

# Is CS installed? Skip if not.
if [ -d "/Applications/Falcon.app" ];
then
    echo "Crowdstrike detected. Starting uninstall."
    
    # Set up variables here

    # Client ID, Client Secret for the API token. Then make base64 version.
    clientid=""
    secret=""
    b64creds=$( printf "$clientid:$secret" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

    # API Base URL and the various endpoints we need
    # Do some autodetection to work out correct URL. Set to default if blank.
    baseurl="https://api.crowdstrike.com"
    baseurl=$( /usr/bin/curl -s -v -X POST -d "client_id=${clientid}&client_secret=${secret}" "${baseurl}/oauth2/token" 2>&1 | awk '($2 == "Location:") {print $3}' | cut -d/ -f1-3 )
[ -z "$baseurl" ] && baseurl="https://api.crowdstrike.com"

    oauthtoken="$baseurl/oauth2/token"
    oauthrevoke="$baseurl/oauth2/revoke"
    maintenancetoken="$baseurl/policy/combined/reveal-uninstall-token/v1"

    # Work out Client ID from current install
    # Remove all - characters otherwise CS API shows erroneous results.
    csfalconstats=$( /Applications/Falcon.app/Contents/Resources/falconctl stats )
    csfalconid=$( echo $csfalconstats | /usr/bin/grep "agentID:" | /usr/bin/awk '{ print $2 }' | /usr/bin/tr -d "-" )

    # Request bearer access token using the API
    token=$( /usr/bin/curl -s -X POST "$oauthtoken" -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=${clientid}&client_secret=${secret}" )

    # Extract the bearer token from the json output above
    bearer=$( /usr/bin/plutil -extract access_token raw -o - - <<< "$token" )

    # Retrieve the uninstall token for the current computer
    # Generate the json required into a variable, pass to the API and extract the token
    data="{
  \"audit_message\": \"Jamf Pro Crowdstrike uninstall script\",
  \"device_id\": \"$csfalconid\"
}"

    jsonoutput=$( /usr/bin/curl -s -X POST "$maintenancetoken" -H "accept: application/json" -H "Content-Type: application/json" -H "authorization: Bearer ${bearer}" -d "$data" )
    uninstalltoken=$( /usr/bin/plutil -extract resources.0.uninstall_token raw -o - - <<< "$jsonoutput" )

    # Invalidate access to the bearer token
    /usr/bin/curl -s -X POST "$oauthrevoke" -H "accept: application/json" -H "authorization: Basic ${b64creds}" -H "Content-Type: application/x-www-form-urlencoded" -d "token=${bearer}"

# Finally action the uninstall using some expect scripting to bypass the interactive part of the token request
/usr/bin/expect <<EOF
set timeout 60
spawn /Applications/Falcon.app/Contents/Resources/falconctl uninstall -t
expect "Falcon Maintenance Token:"
send "$uninstalltoken\r";
expect eof
EOF

else
    echo "Crowdstrike not installed."
fi

# All done!
exit 0
