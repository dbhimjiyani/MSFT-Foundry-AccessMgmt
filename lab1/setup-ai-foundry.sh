#!/bin/bash

# Lab 1: Set up AI Foundry Resource via Azure CLI
# This script creates an Azure AI Foundry resource with necessary dependencies

set -e

# Configuration variables
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-ai-foundry-demo}"
LOCATION="${LOCATION:-eastus}"
AI_FOUNDRY_NAME="${AI_FOUNDRY_NAME:-aifoundry-$RANDOM}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:-storage$RANDOM}"
KEY_VAULT_NAME="${KEY_VAULT_NAME:-kv-foundry-$RANDOM}"

echo "========================================"
echo "Lab 1: Setting up AI Foundry Resource"
echo "========================================"
echo ""

# Check if user is logged in to Azure
echo "Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "❌ You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

echo "✅ Azure login verified"
echo ""

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION_ID"
echo ""

# Create Resource Group
echo "Creating Resource Group: $RESOURCE_GROUP_NAME"
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --tags "Environment=Demo" "Purpose=AIFoundryAccessMgmt"
echo "✅ Resource Group created"
echo ""

# Create Storage Account (required dependency)
echo "Creating Storage Account: $STORAGE_ACCOUNT_NAME"
az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access false
echo "✅ Storage Account created"
echo ""

# Create Key Vault (required dependency)
echo "Creating Key Vault: $KEY_VAULT_NAME"
az keyvault create \
    --name "$KEY_VAULT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --enabled-for-deployment true \
    --enabled-for-template-deployment true
echo "✅ Key Vault created"
echo ""

# Create AI Services (Cognitive Services) account
AI_SERVICES_NAME="ai-services-$RANDOM"
echo "Creating AI Services account: $AI_SERVICES_NAME"
az cognitiveservices account create \
    --name "$AI_SERVICES_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --kind AIServices \
    --sku S0 \
    --location "$LOCATION" \
    --yes
echo "✅ AI Services account created"
echo ""

# Create Azure AI Hub (AI Foundry Hub)
AI_HUB_NAME="aihub-$RANDOM"
echo "Creating AI Hub (AI Foundry Hub): $AI_HUB_NAME"

# Note: Azure AI Hub is created using the 'az ml workspace' command
# as it's part of Azure Machine Learning service infrastructure
az ml workspace create \
    --name "$AI_HUB_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --storage-account "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME" \
    --key-vault "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"

echo "✅ AI Hub created"
echo ""

# Create AI Project (AI Foundry Project)
AI_PROJECT_NAME="aiproject-$RANDOM"
echo "Creating AI Project: $AI_PROJECT_NAME"
az ml workspace create \
    --name "$AI_PROJECT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --kind project \
    --hub-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.MachineLearningServices/workspaces/$AI_HUB_NAME"

echo "✅ AI Project created"
echo ""

# Save configuration for other labs
CONFIG_FILE="ai-foundry-config.env"
cat > "$CONFIG_FILE" <<EOF
# AI Foundry Configuration
# Generated on $(date)
export RESOURCE_GROUP_NAME="$RESOURCE_GROUP_NAME"
export LOCATION="$LOCATION"
export SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_NAME"
export KEY_VAULT_NAME="$KEY_VAULT_NAME"
export AI_SERVICES_NAME="$AI_SERVICES_NAME"
export AI_HUB_NAME="$AI_HUB_NAME"
export AI_PROJECT_NAME="$AI_PROJECT_NAME"
EOF

echo "✅ Configuration saved to $CONFIG_FILE"
echo ""

echo "========================================"
echo "Lab 1 Complete! 🎉"
echo "========================================"
echo ""
echo "Resources created:"
echo "  - Resource Group: $RESOURCE_GROUP_NAME"
echo "  - Storage Account: $STORAGE_ACCOUNT_NAME"
echo "  - Key Vault: $KEY_VAULT_NAME"
echo "  - AI Services: $AI_SERVICES_NAME"
echo "  - AI Hub: $AI_HUB_NAME"
echo "  - AI Project: $AI_PROJECT_NAME"
echo ""
echo "Configuration saved to: $CONFIG_FILE"
echo "Source this file in subsequent labs: source $CONFIG_FILE"
echo ""
echo "Next: Proceed to Lab 2 to set up role-based access control"
