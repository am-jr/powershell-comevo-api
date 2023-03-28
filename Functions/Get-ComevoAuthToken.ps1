function Get-ComevoAuthToken {
    param(
        [CmdletBinding()]
        [parameter(mandatory = $true)]
        $username,
        [parameter(mandatory = $true)]
        [securestring]$password,
        $uri = 'https://api.comevo.com'
    )

    $headers = @{
        'Content-Type' = 'application/json'
        'Accept'       = 'application/json'
    }

    $body = "grant_type=password&username=$username&password=$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))"

    $restArgs = @{
        'URI'     = "$uri/v3/token"
        'Headers' = $headers
        'Body'    = $body
        'Method'  = 'POST'
    }
    $response = Invoke-RestMethod @restArgs
    Return $response.access_token
}