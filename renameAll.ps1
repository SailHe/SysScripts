# �����滻�ļ���

# �������е�ƥ���ַ��� �����滻���ַ����������� �ļ�����ɸѡ
param($oldtext, $newtext, $filter)

# ���屣�����ļ���Ŀ¼ Ϊ�˷�ֹ����� ���˲���д��
$Path = 'F:\Temper\RenameWorkSpace'

# PowerShell3.0֮ǰ $CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
# �ű��ļ�·��
#$Path = $PSScriptRoot

# PowerShell���̵�ǰ����·��
#$Path = "'" + (gi .).FullName.ToString() + "'"

# �����������
#$Filter = '*.png'
$Filter = $filter
#$newtext = 'newName'
# ������ƹ��ڼ򵥱���en���ܻ�: �޷�������ָ����Ŀ�꣬��Ϊ��Ŀ���ʾ·�����豸���ơ�
#$oldtext = 'oldname'
Write-Output('���ַ���' + $oldtext);
Write-Output('���ַ���' + $newtext);
Write-Output('ɸѡ��' + $filter);

$count = 0;
ls $Path -Include $Filter -Recurse | ForEach-Object{
    if($_.FullName.Contains($oldtext)){
        ++$count;
        Rename-Item $_.FullName $_.FullName.Replace($oldtext, $newtext);
    }
}
Write-Output($Path+'������ƥ����ļ�' + $count + '���������ɹ�');
