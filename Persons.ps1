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
     $OracleSQLQuery = $config.PersonsQuery
    
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
    $person = @{}
    $person['ExternalId'] = $row.ID
    $person['DisplayName'] = "$($row.FIRST_NAME) $($row.LAST_NAME) ($($person.ExternalId))"
    $person['Contracts'] = [System.Collections.ArrayList]@()
    $contract = @{ ExternalId = $person.ExternalId }

    foreach($prop in $row.PSObject.properties)
    {
        if(@("RowError","RowState","Table","HasErrors","ItemArray") -contains $prop.Name) { continue; }
        $person[$prop.Name.replace('-','_')] = "$($prop.Value)"
        $contract[$prop.Name.replace('-','_')] = "$($prop.Value)"
    }

    [void]$person.Contracts.Add($contract)

    Write-Output ($person | ConvertTo-Json)
}

Write-Information "Finished Processing Persons"
