function Get-ComevoAttendees {
    param(
        [CmdletBinding()]
        [parameter(mandatory = $true,
            ValueFromPipeline = $true)]
        $Access_Token,
        [parameter(mandatory = $true,
            ValueFromPipeline = $true)]
        [int]$module,
        $uri = 'https://api.comevo.com',
        [bool]$includeTestData = $false,
        [bool]$completed = $true,
        [string]$timeZone = 'Pacific',
        [int]$daysAgo = 7,
        [int]$offset = 0
    )

    $headers = @{
        'Content-Type'  = 'application/json'
        'Accept'        = 'application/json'
        'Authorization' = "Bearer $Access_Token"
    }


    [datetime]$CurrentTime = Get-Date
    $end = Get-Date $CurrentTime -UFormat '%Y-%m-%d'
    $start = Get-Date $CurrentTime.AddDays(-$daysAgo) -UFormat '%Y-%m-%d'


    while ($true) {
        $SearchParameters = @{
            includeTestData = $includeTestData
            completed       = $completed
            timeZone        = $timeZone
            start           = $start
            end             = $end
            offset          = $offset
        }

        #Removing empty search parameters
        @($SearchParameters.keys) | ForEach-Object { if (-not $SearchParameters[$_]) { $SearchParameters.Remove($_) } }

        $uri = "$uri/v3/launch/modules/$module/attendees"

        $HttpValueCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        foreach ($Item in $SearchParameters.GetEnumerator()) {
            if ($Item.Value.Count -gt 0) {
                $HttpValueCollection.Add($Item.Key, $Item.Value)
            }
        }

        $QueryUri = [System.UriBuilder]($Uri)
        $QueryUri.Query = $HttpValueCollection.ToString()

        $queryArgs = @{
            'URI'     = "$($QueryUri.Uri.AbsoluteUri)"
            'Headers' = $headers
            'Method'  = 'GET'
        }

        try {
            $QueryResponse = Invoke-RestMethod @queryArgs
        } catch {
            { break; }
        }

        #Validating that the array isn't adding the same users over and over.
        if ($null -ne $Results -and (@() + $Results.id).Contains($QueryResponse[0].id)) {
            break;
        }
        $Results += $QueryResponse
        $offset = $results.Count

        #Breaking the loop when one of these three is true.
        if ($QueryResponse.lastPage -eq $true -or $null -eq $QueryResponse -or $QueryResponse.Length -eq 0) {
            break
        }
    }
    return $results
}