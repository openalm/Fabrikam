import-module webadministration

$poolName = [String]('IIS:\AppPools\'+$WebAppPoolName)
$pool = get-item($poolName);

$pool.processModel.userName = [String]($UserName)
$pool.processModel.password = [String]($Password)
$pool.processModel.identityType = [String]("SpecificUser");

$pool | Set-Item

