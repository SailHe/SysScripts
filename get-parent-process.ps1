#wmic process where ProcessId=$pid get ParentProcessId
$id = $pid
$instance = Get-CimInstance Win32_Process -Filter "ProcessId = '$id'"
#$instance.ParentProcessId
$parentProcess = Get-Process -Id $instance.ParentProcessId
$parentProcess
