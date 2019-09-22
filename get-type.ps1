param
(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
[Object[]]
$InputObject
)

function Get-Type
{
  param
  (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Object[]]
    $InputObjectArr
  )
   
  process
  {
    $InputObjectArr | ForEach-Object {
      $element = $_
      ($element | Get-Member | findstr "TypeName").Trim()
    }
  }
}


Get-Type($InputObject);

# [PowerShell管道入门，看看你都会不（管道例子大全） - 永远薰薰 - 博客园](https://www.cnblogs.com/lavender000/p/6941393.html)
# [PowerShell接收多个输入 – PowerShell 中文博客](https://www.pstips.net/accepting-multiple-input.html)
