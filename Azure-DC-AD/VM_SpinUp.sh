# Azure Windows Lab Environment Setup Script
# This script creates a secure Windows VM environment using Azure Bastion

# Variables
RESOURCE_GROUP="LabRG"
LOCATION="uksouth"
VM_NAME="WinLabVM"
VNET_NAME="LabVNet"
SUBNET_NAME="LabSubnet"
BASTION_SUBNET_NAME="AzureBastionSubnet"
NSG_NAME="LabNSG"
IP_NAME="LabPublicIP"
BASTION_NAME="LabBastion"
ADMIN_USER="azureuser"
ADMIN_PASS="P@ssw0rd123!"   # 🔴 CRITICAL: Change this to a strong password

echo "🚀 Starting Azure Lab Environment Creation..."

# 1. Create Resource Group
echo "📁 Creating Resource Group: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION

# 2. Create VNet and Subnet
echo "🌐 Creating Virtual Network and Subnet..."
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix 10.0.1.0/24

# 3. Create Bastion Subnet (required /27 or larger)
echo "🛡️ Creating Azure Bastion Subnet..."
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $BASTION_SUBNET_NAME \
  --address-prefix 10.0.255.0/27

# 4. Create Public IP for Bastion (Standard SKU required)
echo "🌍 Creating Public IP for Bastion..."
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name $IP_NAME \
  --sku Standard \
  --allocation-method Static \
  --location $LOCATION

# 5. Create Bastion Host (secure connectivity)
echo "🏰 Creating Azure Bastion Host..."
az network bastion create \
  --resource-group $RESOURCE_GROUP \
  --name $BASTION_NAME \
  --public-ip-address $IP_NAME \
  --vnet-name $VNET_NAME \
  --location $LOCATION

# 6. Create Network Security Group with restrictive rules
echo "🔒 Creating Network Security Group..."
az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name $NSG_NAME \
  --location $LOCATION

# 7. Create Windows VM (NO direct RDP access - Bastion only)
echo "💻 Creating Windows VM..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Win2019Datacenter \
  --admin-username $ADMIN_USER \
  --admin-password $ADMIN_PASS \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --nsg $NSG_NAME \
  --size Standard_B2s \
  --location $LOCATION \
  --public-ip-address "" \
  --storage-sku Standard_LRS

echo "✅ Lab environment created successfully!"
echo ""
echo "🔧 Next Steps:"
echo "1. Connect to VM via Azure Bastion in the Azure Portal"
echo "2. Navigate to: Virtual Machines > $VM_NAME > Connect > Bastion"
echo "3. Use credentials: $ADMIN_USER / [your secure password]"
echo ""
echo "⚠️  Security Notes:"
echo "- VM has no public IP (secure by design)"
echo "- No RDP port 3389 exposed to internet"
echo "- Access only through encrypted Azure Bastion"
echo "- Consider enabling disk encryption and monitoring"

# Optional: Display connection information
echo ""
echo "📊 Resource Summary:"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "VM Name: $VM_NAME"
echo "Admin User: $ADMIN_USER"
echo "Bastion Host: $BASTION_NAME"
