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

# [PowerShell�ܵ����ţ������㶼�᲻���ܵ����Ӵ�ȫ�� - ��Զ޹޹ - ����԰](https://www.cnblogs.com/lavender000/p/6941393.html)
# [PowerShell���ն������ �C PowerShell ���Ĳ���](https://www.pstips.net/accepting-multiple-input.html)
