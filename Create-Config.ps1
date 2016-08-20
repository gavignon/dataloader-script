param(
    
    [parameter(mandatory=$true)]
    [string] $ConfigName,
    
    [parameter(mandatory=$true)]
    [string] $DateFolder,
    
    [parameter(mandatory=$true)]
    [string] $OperationName,
    
    [parameter(mandatory=$true)]
    [string] $Username,
    
    [parameter(mandatory=$true)]
    [string] $Password,
    
    [parameter(mandatory=$true)]
    [string] $DataName,
    
    [parameter(mandatory=$true)]
    [ValidateSet("csvRead", "csvWrite")] 
    [string] $DataType,
    
    [parameter(mandatory=$true)]
    [ValidateSet("extract", "extract all", "insert", "upsert", "update", "delete", "hard delete")] 
    [string] $OperationType,
    
    [parameter()]
    [string] $AssignmentRule = $null,
    
    [parameter()]
    [string] $BatchSize = $null,
    
    [parameter()]
    [switch] $BulkApi = $false,
    
    [parameter()]
    [string] $BulkCheckStatusInterval = $null,
    
    [parameter()]
    [switch] $BulkSerialMode = $false,
    
    [parameter()]
    [switch] $BulkZipContent = $true,
    
    [parameter()]
    [string] $ConnectionTimout = $null,
    
    [parameter()]
    [switch] $DebugMessage = $true,
    
    [parameter()]
    [switch] $EnableRetries = $true,
    
    [parameter()]
    [string] $Entity = $null,
    
    [parameter()]
    [ValidateSet("Production", "Sandbox")] 
    [string] $Environment = "Sandbox",
    
    [parameter()]
    [switch] $EuropeanDates = $true,
    
    [parameter()]
    [string] $ExternalId = $null,
    
    [parameter()]
    [string] $ExtractRequestSize = $null,
    
    [parameter()]
    [string] $InitialLastRun = $null,
    
    [parameter()]
    [switch] $InsertNulls = $false,
    
    [parameter()]
    [switch] $LastRunOutput = $true,
    
    [parameter()]
    [string] $Mapping = $null,
    
    [parameter()]
    [string] $MaxRetries = $null,
    
    [parameter()]
    [string] $MinRetrySecs = $null,
    
    [parameter()]
    [switch] $NoCompression = $false,
    
    [parameter()]
    [string] $Proxy = $null,
    
    [parameter()]
    [string] $ProxyUsername = $null,
    
    [parameter()]
    [string] $ProxyPassword = $null,
    
    [parameter()]
    [string] $ReadBatchSize = $null,
    
    [parameter()]
    [string] $ReadUTF8 = $null,
    
    [parameter()]
    [string] $SoqlQuery = $null,
    
    [parameter()]
    [string] $StartRow = $null,
    
    [parameter()]
    [switch] $StatusOutput = $true,
    
    [parameter()]
    [string] $Timeout = $null,
    
    [parameter()]
    [string] $Timezone = $null,
    
    [parameter()]
    [switch] $TruncateFields = $true,
    
    [parameter()]
    [string] $WriteBatchSize = $null,
    
    [parameter()]
    [switch] $WriteUTF8 = $true
    
)
    
$Prefix = ($PSScriptRoot -replace "\\", "\\")

# Set mandatory parameters
$params = [Ordered]@{
    "sfdc.debugMessagesFile" = "$Prefix\\logs\\$ConfigName\\$DateFolder\\debug_$OperationName.log";
    "sfdc.endpoint" = "https://$(@{"Production"="login";"Sandbox"="test"}[$Environment]).salesforce.com";
    "sfdc.username" = $Username;
    "sfdc.password" = $Password;
    "dataAccess.name" = "$Prefix\\$(Split-Path $DataName)\\$ConfigName\\$DateFolder\\$($DataName -replace "\$(Split-Path $DataName)")";
    "dataAccess.type" = $DataType;
    "process.encryptionKeyFile" = "$Prefix\\passphrase.key";
    "process.operation" = $OperationType;
    "process.lastRunOutputDirectory" = "$Prefix\\output\\runs\\";
    "process.statusOutputDirectory" = "$Prefix\\output\\$ConfigName\\$DateFolder\\";
    "process.outputError" = "$Prefix\\output\\$ConfigName\\$DateFolder\\error_$OperationName.csv";
    "process.outputSuccess" = "$Prefix\\output\\$ConfigName\\$DateFolder\\success_$OperationName.csv"
}

# Set ProxyHost and ProxyPort
if($Proxy)
{
    $SplitProxy = $Proxy.split(":")
    $params["sfdc.proxyHost"] = $SplitProxy[0]
    $params["sfdc.proxyPort"] = $SplitProxy[1]
    if($ProxyUsername){ $params["sfdc.proxyUsername"] = $ProxyUsername }
    if($ProxyPassword){ $params["sfdc.proxyPassword"] = $ProxyPassword }
}

# Optional parameters
if($AssignmentRule){ $params["sfdc.assignmentRule"] = $AssignmentRule }
if($BatchSize){ $params["sfdc.loadBatchSize"] = $BatchSize }
if($BulkApi){ $params["sfdc.useBulkApi"] = "true" }
if($BulkCheckStatusInterval){ $params["sfdc.bulkApiCheckStatusInterval"] = $BulkCheckStatusInterval }
if($BulkSerialMode){ $params["sfdc.bulkApiSerialMode"] = "true" }
if(-not $BulkZipContent){ $params["sfdc.bulkApiZipContent"] = "false" }
if($ConnectionTimout){ $params["sfdc.connectionTimeoutSecs"] = $ConnectionTimout }
if(-not $DebugMessage){ $params["sfdc.debugMessages"] = "false" }
if(-not $EnableRetries){ $params["sfdc.enableRetries"] = "false" }
if($Entity){ $params["sfdc.entity"] = $Entity }
if(-not $EuropeanDates){ $params["process.useEuropeanDates"] = "false" }
if($ExternalId){ $params["sfdc.externalIdField"] = $ExternalId }
if($ExtractRequestSize){ $params["sfdc.extractionRequestSize"] = $ExtractRequestSize }
if($InitialLastRun){ $params["process.initialLastRunDate"] = $InitialLastRun }
if($InsertNulls){ $params["sfdc.insertNulls"] = "true" }
if(-not $LastRunOutput){ $params["process.enableLastRunOutput"] = "false" }
if($Mapping){ $params["process.mappingFile"] = "$Prefix\\mapping\\$Mapping" }
if($MaxRetries){ $params["sfdc.maxRetries"] = $MaxRetries }
if($MinRetrySecs){ $params["sfdc.minRetrySleepSecs"] = $MinRetrySecs }
if($NoCompression){ $params["sfdc.noCompression"] = "true" }
if($ReadBatchSize){ $params["dataAccess.readBatchSize"] = $ReadBatchSize }
if($ReadUTF8){ $params["dataAccess.readUTF8"] = $ReadUTF8 }
if($SoqlQuery){ $params["sfdc.extractionSOQL"] = $SoqlQuery }
if($StartRow){ $params["process.loadRowToStartAt"] = $StartRow }
if(-not $StatusOutput){ $params["process.enableExtractStatusOutput"] = "false" }
if($TimeOut){ $params["sfdc.timeoutSecs"] = $TimeOut }
if($Timezone){ $params["sfdc.timezone"] = $Timezone }
if(-not $TruncateFields){ $params["sfdc.truncateFields"] = "false" }
if($WriteBatchSize){ $params["dataAccess.writeBatchSize"] = $WriteBatchSize }
if(-not $WriteUTF8){ $params["dataAccess.writeUTF8"] = "false" }

# Generate config file from hash
$output = ""
foreach($p in $params.GetEnumerator())
{
    $output += "$($p.key)=$($p.value)`n"
}

mkdir -Path "$Prefix\output\$ConfigName\\$DateFolder", "$Prefix\output\runs", "$Prefix\conf" -ErrorAction SilentlyContinue | Out-Null
#"$Prefix\logs\$date", 

$output | Out-File -Force -FilePath "$Prefix\conf\config.properties" -Encoding utf8

