
//backEndUri stores first line from user input file
backEndUri="$(sed -n 1p < userinputfile)"
//iotHubConString stores second line from user input file
iotHubConString="$(sed -n 2p < userinputfile)"
//StgAcntName stores third line from user input file
StgAcntName="$(sed -n 3p < userinputfile)"
//StgAcntkey stores fourth line from user input file
StgAcntKey="$(sed -n 4p < userinputfile)"
//Replaces the backEnd  url in config.js file
sed -i "s|<backendUrl>|${backEndUri}|g" ./config.js
//Replaces the Iot Hub connection string in config.js file
sed -i "s|<IOTHubConnectionString>|${iotHubConString}|g" ./config.js
//Replaces the Storage Account name in config.js file
sed -i "s|<storageAccountName>|${StgAcntName}|g" ./config.js
//Replaces the Storage Account Access key in config.js file
sed -i "s|<storageAccountAccessKey>|${StgAcntKey}|g" ./config.js
