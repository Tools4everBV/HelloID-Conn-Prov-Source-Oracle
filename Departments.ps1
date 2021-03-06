$config = ConvertFrom-Json $configuration;

$Assembly = [System.Reflection.Assembly]::LoadWithPartialName("System.Data.OracleClient")

if ( $Assembly ) {
     Write-Information "System.Data.OracleClient Loaded!"
 }
 else {
     Write-Error "System.Data.OracleClient could not be loaded!"
 }
 
 ### connection string ###
 $OracleConnectionString = "SERVER=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$($config.dataSource))(PORT=$($config.Port))))(CONNECT_DATA=(SERVICE_NAME=$($config.ServiceName))));Uid=$($config.Username);Pwd=$($config.Password)"
 
 ### open up oracle connection to database ###
 $OracleConnection = New-Object System.Data.OracleClient.OracleConnection($OracleConnectionString);
 $OracleConnection.Open()
    
 try {
    
     ### sql query command ###
     $OracleSQLQuery = $config.departmentsQuery
    
     ### create object ###
     $SelectCommand1 = New-Object System.Data.OracleClient.OracleCommand;
     $SelectCommand1.Connection = $OracleConnection
     $SelectCommand1.CommandText = $OracleSQLQuery
     $SelectCommand1.CommandType = [System.Data.CommandType]::Text
    
     ### create datatable and load results into datatable ###
     $SelectDataTable = New-Object System.Data.DataTable
     $SelectDataTable.Load($SelectCommand1.ExecuteReader())
 }
 catch {
     Write-Error "Error while retrieving data!"
 }

 $OracleConnection.Close()
 
foreach($row in $SelectDataTable)
{
    $row = @{
              ExternalId = $row.Id
              DisplayName = $row.Name
              Name        = $row.Name
    }
 
    $row | ConvertTo-Json -Depth 10
}

Write-Information "Finished Processing Departments"
