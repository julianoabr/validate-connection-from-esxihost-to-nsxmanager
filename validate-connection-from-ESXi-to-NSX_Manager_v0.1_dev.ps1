#Get network connections on port 1234 on esxis

<#
This script works exactly like command below, but it runs on all Hosts in a vCenter Server

esxcli network ip connection list | grep 1234
tcp         0       0  10.143.37.232:59631  10.143.37.245:1234   ESTABLISHED     67916  newreno  netcpa
tcp         0       0  10.143.37.232:37095  10.143.37.246:1234   ESTABLISHED     67916  newreno  netcpa
tcp         0       0  10.143.37.232:22900  10.143.37.247:1234   ESTABLISHED     67916  newreno  netcpa

Communication Ports of NSX

NSX 2.5, 3.0, 3.1, 3.2
NSX Edge nodes
NSX Manager
1234 TCP
-
NSX Messaging channel to NSX Manager
NSX 2.5, 3.0, 3.1, 3.2
KVM host
NSX Manager
1234 TCP


NSX Messaging channel to NSX Manager. AMPQ Communication channel to NSX Manager


NSX 2.5, 3.0, 3.1, 3.2
ESXi host
NSX Manager
1234 TCP

NSX Messaging channel to NSX Manager. AMPQ Communication channel to NSX Manager

#>

Clear-Host

$actualDate = (Get-date -Format "ddMMyyyy-HHmm").ToString()

$outputPath = "$env:SystemDrive:\Temp"

$hostClusterList = @()

$hostClusterList = VMware.VimAutomation.Core\Get-Cluster | Select-Object -ExpandProperty Name | Sort-Object


foreach ($hostCluster in $HostClusterList)
{
    
$esxiHostList = @()

$esxiHostList =  VMware.VimAutomation.Core\Get-VMHost -Location $hostCluster | Select-Object -ExpandProperty Name | Sort-Object

    foreach ($esxiHost in $esxiHostList)
                        {
        $esxcli = Get-EsxCli -VMHost (VMware.VimAutomation.Core\Get-VMHost -Name $esxiHost) -V2

        Write-Output "Status Connection to Remote Port 1234 on ESXi Host: $esxiHost is:" | Out-File -Width 2048 -FilePath "$outputPath\ConnectOnPort-$hostCluster-$actualDate.txt" -Append

        Write-Output "`n" | Out-File -Width 2048 -FilePath "$outputPath\ConnectOnPort-$hostCluster-$actualDate.txt" -Append

        $esxcli.network.ip.connection.list.invoke() | Where-Object -FilterScript {$_.ForeignAddress -like "*:1234"} | 
        Select-Object -Property Proto,RecvQ,SendQ,LocalAddress,ForeignAddress,State,WorldID,CCAlgo,WorldName | Format-Table -AutoSize | Out-File -Width 2048 -FilePath "$outputPath\ConnectOnPort-$hostCluster-$actualDate.txt" -Append


    }#inside foreach (host level)

}#main foreach (cluster level)














