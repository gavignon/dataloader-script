
param(    
    [parameter()]
    [string] $ConfigFile = "$PSScriptRoot\processes\config.json",
    
    [parameter()]
    [switch] $DebugMessage = $true
)

# Function declaration
function encryptPassword($Pwd){
    Push-Location (Split-Path $Encrypter)
    $EncryptedPwd = (& $Encrypter -e $Pwd "$PSScriptRoot\\passphrase.key") -match "- .*$"
    Pop-Location
    return ($matches[0] -replace "- ")
}

Write-Output "COUCOU"

# Initialization
$date = get-date -Format "yyyy-MM-dd_HH-mm"
$InstallPath = "$Env:LOCALAPPDATA\salesforce.com\Data Loader"
$Dataloader = "$InstallPath\bin\process.bat"
$Encrypter = "$InstallPath\bin\encrypt.bat"

# Use config file for the process
$Json = (cat $ConfigFile | convertfrom-json)
$Operations = @()
$Json.Operations | % {
    $tmp = @{}
    $_.PSObject.Properties | % { $tmp[$_.Name] = $_.Value }
    $Operations += $tmp
}

# Encrypt provided password
if($Json.EncryptPassword){
    $EncryptedPassword = encryptPassword -Pwd $Json.Password
}else{
    $EncryptedPassword = $Json.Password
}

# Create log directory
$Path = $PSScriptRoot
mkdir -Path "$Path\logs\$($Json.Name)\$date" -ErrorAction SilentlyContinue | Out-Null

foreach($op in $Operations)
{
    
    # Generate config file
    & "$Path\Create-Config.ps1" `
        -ConfigName $Json.Name `
        -DateFolder $date `
        -Username $Json.Username `
        -Password $EncryptedPassword `
        -Environment $Json.Environment `
        -TimeOut $Json.Timeout `
        -Proxy $Json.Proxy `
        -DebugMessage:$DebugMessage `
        @op
    
    # Call Process
    Push-Location (Split-Path $Dataloader)
    & $Dataloader "$Path\conf" "process" >> "$Path\logs\$($Json.Name)\$date.log"
    Pop-Location
    
    # Backup generated config files
    mv "$Path\conf\config.properties" "$Path\logs\$($Json.Name)\$date\config_$($op.OperationName).properties" -Force
    # Delete conf files except process-conf.xml
    ls "$Path\conf" | ? name -ne "process-conf.xml" | ? name -ne "log-conf.xml" | rm
}

# Compress-Archive -LiteralPath C:\Reference\first.doc, C:\Reference\second.doc -CompressionLevel Optimal -DestinationPath C:\Archives\file.zip
# if((Get-Item '.\file.zip').length -lt 15Mb){}
# Send-MailMessage -To $Json.EmailContacts -Subject "Test mail" -From "dataloader@gilavignon.com" -Body "DataLoader $Json.Name Report" -SmtpServer "smtp.gmail.com" -Port 587 -Credential "avignon.gil@gmail.com"