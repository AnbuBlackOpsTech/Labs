# Azure Windows Lab Environment Setup Script - PowerShell
# This script creates a secure Windows VM environment using Azure Bastion

# Variables
$ResourceGroup = "LabRG"
$Location = "uksouth"
$VmName = "WinLabVM"
$VNetName = "LabVNet"
$SubnetName = "LabSubnet"
$BastionSubnetName = "AzureBastionSubnet"
$NsgName = "LabNSG"
$PublicIpName = "LabPublicIP"
$BastionName = "LabBastion"
$AdminUser = "azureuser"
$AdminPass = "P@ssw0rd123!"   # 🔴 CRITICAL: Change this to a strong password

# Convert password to secure string
$SecurePassword = ConvertTo-SecureString $AdminPass -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($AdminUser, $SecurePassword)

Write-Host "🚀 Starting Azure Lab Environment Creation..." -ForegroundColor Green

try {
    # 1. Create Resource Group
    Write-Host "📁 Creating Resource Group: $ResourceGroup" -ForegroundColor Yellow
    New-AzResourceGroup -Name $ResourceGroup -Location $Location -Force

    # 2. Create Network Security Group with restrictive rules
    Write-Host "🔒 Creating Network Security Group..." -ForegroundColor Yellow
    New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Name $NsgName -Location $Location -Force

    # 3. Create VNet and VM Subnet
    Write-Host "🌐 Creating Virtual Network and Subnet..." -ForegroundColor Yellow
    $VmSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix "10.0.1.0/24"
    
    # 4. Create Bastion Subnet (required /27 or larger)
    Write-Host "🛡️ Creating Azure Bastion Subnet..." -ForegroundColor Yellow
    $BastionSubnet = New-AzVirtualNetworkSubnetConfig -Name $BastionSubnetName -AddressPrefix "10.0.255.0/27"
    
    # Create VNet with both subnets
    $VNet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name $VNetName -Location $Location -AddressPrefix "10.0.0.0/16" -Subnet $VmSubnet, $BastionSubnet

    # 5. Create Public IP for Bastion (Standard SKU required)
    Write-Host "🌍 Creating Public IP for Bastion..." -ForegroundColor Yellow
    $PublicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup -Name $PublicIpName -Location $Location -Sku "Standard" -AllocationMethod "Static"

    # 6. Create Bastion Host (secure connectivity)
    Write-Host "🏰 Creating Azure Bastion Host (this may take 10-15 minutes)..." -ForegroundColor Yellow
    $Bastion = New-AzBastion -ResourceGroupName $ResourceGroup -Name $BastionName -PublicIpAddress $PublicIp -VirtualNetwork $VNet

    # 7. Get Network Security Group
    $Nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Name $NsgName

    # 8. Create Network Interface for VM (no public IP)
    Write-Host "🔌 Creating Network Interface..." -ForegroundColor Yellow
    $VmSubnetRef = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet -Name $SubnetName
    $Nic = New-AzNetworkInterface -ResourceGroupName $ResourceGroup -Name "$VmName-nic" -Location $Location -SubnetId $VmSubnetRef.Id -NetworkSecurityGroupId $Nsg.Id

    # 9. Create VM Configuration
    Write-Host "💻 Creating Windows VM..." -ForegroundColor Yellow
    $VmConfig = New-AzVMConfig -VMName $VmName -VMSize "Standard_B2s"
    $VmConfig = Set-AzVMOperatingSystem -VM $VmConfig -Windows -ComputerName $VmName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VmConfig = Set-AzVMSourceImage -VM $VmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
    $VmConfig = Add-AzVMNetworkInterface -VM $VmConfig -Id $Nic.Id
    $VmConfig = Set-AzVMBootDiagnostic -VM $VmConfig -Disable

    # 10. Create the Virtual Machine
    New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VmConfig -Verbose

    Write-Host "✅ Lab environment created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔧 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Connect to VM via Azure Bastion in the Azure Portal" -ForegroundColor White
    Write-Host "2. Navigate to: Virtual Machines > $VmName > Connect > Bastion" -ForegroundColor White
    Write-Host "3. Use credentials: $AdminUser / [your secure password]" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  Security Notes:" -ForegroundColor Yellow
    Write-Host "- VM has no public IP (secure by design)" -ForegroundColor White
    Write-Host "- No RDP port 3389 exposed to internet" -ForegroundColor White
    Write-Host "- Access only through encrypted Azure Bastion" -ForegroundColor White
    Write-Host "- Consider enabling disk encryption and monitoring" -ForegroundColor White

    # Display resource summary
    Write-Host ""
    Write-Host "📊 Resource Summary:" -ForegroundColor Magenta
    Write-Host "Resource Group: $ResourceGroup" -ForegroundColor White
    Write-Host "Location: $Location" -ForegroundColor White
    Write-Host "VM Name: $VmName" -ForegroundColor White
    Write-Host "Admin User: $AdminUser" -ForegroundColor White
    Write-Host "Bastion Host: $BastionName" -ForegroundColor White

    # Optional: Get VM details
    Write-Host ""
    Write-Host "🔍 VM Details:" -ForegroundColor Cyan
    $VM = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName
    Write-Host "VM Size: $($VM.HardwareProfile.VmSize)" -ForegroundColor White
    Write-Host "OS Type: $($VM.StorageProfile.OsDisk.OsType)" -ForegroundColor White
    Write-Host "Private IP: $($Nic.IpConfigurations[0].PrivateIpAddress)" -ForegroundColor White

}
catch {
    Write-Host "❌ Error occurred during deployment:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "🧹 To clean up partial deployment, run:" -ForegroundColor Yellow
    Write-Host "Remove-AzResourceGroup -Name '$ResourceGroup' -Force" -ForegroundColor White
}

# Optional cleanup script (commented out)
<#
Write-Host ""
Write-Host "🧹 To delete all resources later, run:" -ForegroundColor Yellow
Write-Host "Remove-AzResourceGroup -Name '$ResourceGroup' -Force" -ForegroundColor White
#>

Write-Host ""
Write-Host "💰 Estimated Monthly Cost:" -ForegroundColor Cyan
Write-Host "- Azure Bastion: ~$140 USD" -ForegroundColor White
Write-Host "- Standard_B2s VM: ~$60 USD" -ForegroundColor White  
Write-Host "- Storage & Networking: ~$10 USD" -ForegroundColor White
Write-Host "- Total: ~$210 USD/month" -ForegroundColor Yellow
