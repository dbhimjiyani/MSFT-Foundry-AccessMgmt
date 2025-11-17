#!/bin/bash

# Lab 4: Clean Up Resources
# This script safely removes all resources created in previous labs

set -e

echo "========================================"
echo "Lab 4: Resource Cleanup"
echo "========================================"
echo ""

# Load configuration from Lab 1 if available
if [ -f "../lab1/ai-foundry-config.env" ]; then
    source ../lab1/ai-foundry-config.env
    echo "✅ Loaded configuration from Lab 1"
    HAS_CONFIG=true
else
    echo "⚠️  Configuration file not found. Will attempt cleanup with manual input."
    HAS_CONFIG=false
fi

echo ""

# Verify Azure login
if ! az account show &> /dev/null; then
    echo "❌ You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION_ID"
echo ""

# If no config, ask for resource group name
if [ "$HAS_CONFIG" = false ]; then
    read -p "Enter Resource Group name to delete: " RESOURCE_GROUP_NAME
    if [ -z "$RESOURCE_GROUP_NAME" ]; then
        echo "❌ Resource Group name is required"
        exit 1
    fi
fi

# Confirm deletion
echo "⚠️  WARNING: This will delete the following:"
echo "   - Resource Group: $RESOURCE_GROUP_NAME"
echo "   - All resources within the resource group"
echo "   - Policy assignments"
echo "   - Policy definitions"
echo "   - Custom role definitions"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo ""
echo "Starting cleanup process..."
echo ""

# Step 1: Remove policy assignments
echo "Step 1: Removing policy assignments..."

if az policy assignment list --resource-group "$RESOURCE_GROUP_NAME" --query "[].name" -o tsv | grep -q .; then
    for assignment in $(az policy assignment list --resource-group "$RESOURCE_GROUP_NAME" --query "[].name" -o tsv); do
        echo "  Removing assignment: $assignment"
        az policy assignment delete --name "$assignment" --resource-group "$RESOURCE_GROUP_NAME" || echo "  ⚠️  Failed to remove assignment"
    done
    echo "✅ Policy assignments removed"
else
    echo "  No policy assignments found"
fi

echo ""

# Step 2: Delete custom policy definitions
echo "Step 2: Removing custom policy definitions..."

POLICY_NAMES=("deepseek-deployment-approval" "deepseek-deployment-audit")
for policy_name in "${POLICY_NAMES[@]}"; do
    if az policy definition show --name "$policy_name" --subscription "$SUBSCRIPTION_ID" &> /dev/null; then
        echo "  Removing policy: $policy_name"
        az policy definition delete --name "$policy_name" --subscription "$SUBSCRIPTION_ID" || echo "  ⚠️  Failed to remove policy"
    else
        echo "  Policy not found: $policy_name"
    fi
done

echo "✅ Policy definitions cleaned up"
echo ""

# Step 3: Delete custom role definitions
echo "Step 3: Removing custom role definitions..."

ROLE_NAME="DeepSeek Model Reader"
if az role definition list --name "$ROLE_NAME" --query "[].name" -o tsv | grep -q .; then
    echo "  Removing role: $ROLE_NAME"
    # First, remove any role assignments
    for assignment in $(az role assignment list --role "$ROLE_NAME" --query "[].id" -o tsv); do
        echo "    Removing role assignment: $assignment"
        az role assignment delete --ids "$assignment" || echo "    ⚠️  Failed to remove assignment"
    done
    
    # Then delete the role definition
    az role definition delete --name "$ROLE_NAME" || echo "  ⚠️  Failed to remove role"
    echo "✅ Custom role removed"
else
    echo "  Custom role not found"
fi

echo ""

# Step 4: Delete the resource group (this deletes all resources within it)
echo "Step 4: Deleting resource group and all resources..."
echo "  This may take several minutes..."

if az group exists --name "$RESOURCE_GROUP_NAME" | grep -q "true"; then
    az group delete \
        --name "$RESOURCE_GROUP_NAME" \
        --yes \
        --no-wait
    
    echo "✅ Resource group deletion initiated"
    echo "  Note: Deletion is running in the background and may take 5-10 minutes"
    echo ""
    echo "  To check deletion status:"
    echo "  az group show --name $RESOURCE_GROUP_NAME"
else
    echo "  Resource group not found or already deleted"
fi

echo ""

# Step 5: Clean up local configuration files
echo "Step 5: Cleaning up local configuration files..."

CONFIG_FILES=(
    "../lab1/ai-foundry-config.env"
    "../lab2/rbac-config.env"
    "../lab2/deepseek-reader-role-deployed.json"
    "../lab2/role-permissions-summary.md"
    "../lab3/policy-config.env"
    "../lab3/deployment-workflow.md"
    "../lab3/testing-guide.md"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "  Removed: $file"
    fi
done

echo "✅ Local configuration files cleaned up"
echo ""

# Create cleanup summary
CLEANUP_SUMMARY="cleanup-summary.txt"
cat > "$CLEANUP_SUMMARY" <<EOF
Cleanup Summary
===============
Date: $(date)
Subscription: $SUBSCRIPTION_ID
Resource Group: $RESOURCE_GROUP_NAME

Resources Cleaned Up:
- Policy assignments removed
- Custom policy definitions deleted:
  * deepseek-deployment-approval
  * deepseek-deployment-audit
- Custom role definition deleted:
  * DeepSeek Model Reader
- Resource group deletion initiated:
  * $RESOURCE_GROUP_NAME (and all contained resources)

Note: Resource group deletion runs asynchronously and may take 5-10 minutes to complete.

Verify Cleanup:
1. Check resource group status:
   az group show --name $RESOURCE_GROUP_NAME

2. List remaining policy definitions:
   az policy definition list --query "[?contains(name, 'deepseek')]" --output table

3. List remaining custom roles:
   az role definition list --custom-role-only true --query "[?contains(roleName, 'DeepSeek')]" --output table

If you see any remaining resources, you may need to manually delete them.
EOF

echo "✅ Cleanup summary saved to: $CLEANUP_SUMMARY"
echo ""

echo "========================================"
echo "Lab 4 Complete! 🎉"
echo "========================================"
echo ""
echo "Cleanup Summary:"
echo "  - Policy assignments: Removed"
echo "  - Policy definitions: Deleted"
echo "  - Custom roles: Deleted"
echo "  - Resource group: Deletion initiated (runs in background)"
echo "  - Local config files: Cleaned up"
echo ""
echo "⏱️  Note: Resource group deletion may take 5-10 minutes to complete."
echo ""
echo "To verify cleanup is complete:"
echo "  az group show --name $RESOURCE_GROUP_NAME"
echo "  (Should return an error once deletion is complete)"
echo ""
echo "Thank you for completing the AI Foundry Access Management labs!"
