![Dataloader-script Logo](http://img15.hostingpics.net/pics/653809powershellSFsmall.png)

User Guide
===================

**DataLoader Script** helps you to use [Salesforce.com](www.salesforce.com) Data Loader tool easily and be able to automatize data loading.

----------
Architecture
-------------
* **conf  :** Contain generated Dataloader configuration files
* **input :** Contain input data (to insert or update records)
* **logs :** Folder used to store process logs
* **mapping :** Store Salesforce Dataloader mapping files
* **output :** Store Output files (exported records etc...)
* **processes :** Folder used to store custom processes (see a Configuration file example below)
* Create-Config.ps1 (This script generates Dataloader configuration file)
* Main.ps1 (The main script)
* Run.bat (A simple bat to start the script on Windows)

----------
Setup
-------------

First you have to install Data Loader tool from a Salesforce.com Organization (*Setup > Administration Setup > Data Management > Data Loader*). 

Check if your installation folder is still located in your Local AppData folder. 
**If not** you will have to edit the Main.ps1 script and change the Data Loader path :

`$InstallPath = "$Env:LOCALAPPDATA\salesforce.com\Data Loader"`

### Configuration File

**DataLoader Script** can be launched with a specified configuration file. 
This file is in **JSON** format and can have following attributes:

* **Name :** Configuration name (used for logs folder name)
* **Username :** Salesforce.com application username
* **Password :** Salesforce.com application password (can be already encrypted,  but the next attribute must be equals to false)
* **EncryptPassword :** Boolean, true if Password attribute is not encrypted yet
* **Environment:** Salesforce.com application environment name. 
	* "production"
	* "sandbox" (default)
* **Timeout (optional):** Dataloader timeout (in ms)
	* Default value: "600"
* **EmailAlert (optional):** Boolean, true if you want to send an email when the process ends.
* **EmailContacts (optional):** List of email to send the email
* **Operations:** List of each operation configuration
	* ***OperationName:*** Operation name (used fo logs)
	* ***OperationType:***  Operation type (match with process.operation Data loader parameter)
		* "extract"
		* "extract all"
		* "insert"
		* "upsert"
		* "update"
		* "delete"
		* "hard delete"
	* ***Entity:*** Salesforce entity (Account, Contact etc...)
	* ***Mapping:*** Mapping file (.sdl) path. Relative to the script folder.
	* ***BulkApi:*** Boolean, true if you want to use BulkApi
	* ***BulkSize:*** If BulkApi is used, specify the Bulk size. 
		* Default value: "200"
	* ***DataType:*** 
		* "csvWrite"
		* "csvRead"
		* "databaseWrite"
		* "databaseRead"
	* ***SoqlQuery (optional):*** SOQL query for data extraction
	* ***DataPath:***


Example:
```json
{
    "Name": "Configuration Name",
    "Username": "username@domain.com",
    "Password": "password+Token",
    "EncryptPassword": false,
    "Environment": "sandbox",
    "Timeout": "600",
    "EmailAlert": true,
    "EmailContacts": [
            "email@domain.com"
    ],
    "Operations": [
        {
            "OperationName": "Process Name",
            "OperationType": "extract",
            "Entity": "Account",
            "DataType": "csvWrite",
            "SoqlQuery": "SELECT Id, Name FROM Account",
            "DataName": "\\output\\extractAccount.csv"
        }
    ] 
}
```