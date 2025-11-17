#!/bin/bash

# Lab 2: Set up Role-Based Access Control (RBAC)
# This script creates a custom role for read-only access to DeepSeek models

set -e

# Load configuration from Lab 1
if [ -f "../lab1/ai-foundry-config.env" ]; then
    source ../lab1/ai-foundry-config.env
    echo "✅ Loaded configuration from Lab 1"
else
    echo "❌ Configuration file not found. Please run Lab 1 first."
    echo "Expected file: ../lab1/ai-foundry-config.env"
    exit 1
fi

echo "========================================"
echo "Lab 2: Setting up RBAC for DeepSeek Models"
echo "========================================"
echo ""

# Verify Azure login
if ! az account show &> /dev/null; then
    echo "❌ You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

echo "Using Resource Group: $RESOURCE_GROUP_NAME"
echo "Using Subscription: $SUBSCRIPTION_ID"
echo ""

# Create custom role definition
ROLE_FILE="deepseek-reader-role.json"
ROLE_DEF_FILE="deepseek-reader-role-deployed.json"

echo "Creating custom role definition for DeepSeek Model Reader..."

# Update the role definition with the actual subscription ID
cat "$ROLE_FILE" | sed "s/{subscription-id}/$SUBSCRIPTION_ID/g" > "$ROLE_DEF_FILE"

# Create the custom role
ROLE_NAME="DeepSeek Model Reader"
echo "Creating custom role: $ROLE_NAME"

if az role definition list --name "$ROLE_NAME" --query "[].name" -o tsv | grep -q "."; then
    echo "⚠️  Custom role already exists. Updating..."
    az role definition update --role-definition "$ROLE_DEF_FILE"
    echo "✅ Custom role updated"
else
    az role definition create --role-definition "$ROLE_DEF_FILE"
    echo "✅ Custom role created"
fi

echo ""

# Get the custom role ID
CUSTOM_ROLE_ID=$(az role definition list --name "$ROLE_NAME" --query "[0].id" -o tsv)
echo "Custom Role ID: $CUSTOM_ROLE_ID"
echo ""

# Get resource IDs
AI_HUB_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.MachineLearningServices/workspaces/$AI_HUB_NAME"
AI_PROJECT_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.MachineLearningServices/workspaces/$AI_PROJECT_NAME"
AI_SERVICES_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.CognitiveServices/accounts/$AI_SERVICES_NAME"

# Get current user
CURRENT_USER=$(az account show --query user.name -o tsv)
echo "Current user: $CURRENT_USER"
echo ""

# Demonstrate role assignment (optional)
echo "========================================"
echo "Role Assignment Instructions"
echo "========================================"
echo ""
echo "To assign the 'DeepSeek Model Reader' role to a non-admin user:"
echo ""
echo "1. Assign at Resource Group level (all resources):"
echo "   az role assignment create \\"
echo "     --assignee <user-email-or-object-id> \\"
echo "     --role \"$ROLE_NAME\" \\"
echo "     --scope \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME\""
echo ""
echo "2. Assign at AI Hub level:"
echo "   az role assignment create \\"
echo "     --assignee <user-email-or-object-id> \\"
echo "     --role \"$ROLE_NAME\" \\"
echo "     --scope \"$AI_HUB_ID\""
echo ""
echo "3. Assign at AI Project level:"
echo "   az role assignment create \\"
echo "     --assignee <user-email-or-object-id> \\"
echo "     --role \"$ROLE_NAME\" \\"
echo "     --scope \"$AI_PROJECT_ID\""
echo ""
echo "4. Verify role assignment:"
echo "   az role assignment list \\"
echo "     --assignee <user-email-or-object-id> \\"
echo "     --scope \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME\" \\"
echo "     --output table"
echo ""

# Create documentation of role permissions
PERMISSIONS_FILE="role-permissions-summary.md"
cat > "$PERMISSIONS_FILE" <<EOF
# DeepSeek Model Reader Role - Permissions Summary

## Role Overview

**Role Name**: DeepSeek Model Reader
**Type**: Custom Role
**Purpose**: Provides read-only access to DeepSeek models and endpoints

## Allowed Actions

Users with this role can:

- ✅ View AI Hub/Project workspaces
- ✅ Read model information and metadata
- ✅ View model versions
- ✅ Read endpoint configurations
- ✅ View online endpoint details
- ✅ Read AI Services account information
- ✅ List API keys for inference

## Denied Actions

Users with this role cannot:

- ❌ Deploy new models
- ❌ Delete existing models
- ❌ Modify model configurations
- ❌ Create or delete endpoints
- ❌ Modify endpoint settings
- ❌ Create or delete deployments

## Use Case

This role is ideal for:

- Data scientists who need to use pre-deployed DeepSeek models
- Developers integrating with existing model endpoints
- QA teams testing model inference capabilities
- Non-admin users who should have read-only access

## Admin vs Non-Admin Comparison

| Action | Admin (Owner/Contributor) | Non-Admin (DeepSeek Reader) |
|--------|---------------------------|------------------------------|
| View Models | ✅ Yes | ✅ Yes |
| Use Model Endpoints | ✅ Yes | ✅ Yes |
| Deploy Models | ✅ Yes | ❌ No |
| Delete Models | ✅ Yes | ❌ No |
| Modify Deployments | ✅ Yes | ❌ No |

## Security Considerations

1. **Principle of Least Privilege**: This role follows the principle by granting only necessary read permissions
2. **API Key Access**: Users can read API keys, so they can make inference calls
3. **Audit Trail**: All access is logged in Azure Activity Logs
4. **Scope Control**: Role can be assigned at subscription, resource group, or resource level

## Assignment Scope Recommendations

- **Resource Group Scope**: For users who need access to all AI resources in the group
- **AI Hub Scope**: For users working across multiple projects within a hub
- **AI Project Scope**: For users working on a specific project only

## Next Steps

Proceed to Lab 3 to implement Azure Policy for deployment governance.
EOF

echo "✅ Role permissions documented in: $PERMISSIONS_FILE"
echo ""

# Save updated configuration
CONFIG_FILE="rbac-config.env"
cat > "$CONFIG_FILE" <<EOF
# RBAC Configuration
# Generated on $(date)
export CUSTOM_ROLE_NAME="$ROLE_NAME"
export CUSTOM_ROLE_ID="$CUSTOM_ROLE_ID"
export AI_HUB_ID="$AI_HUB_ID"
export AI_PROJECT_ID="$AI_PROJECT_ID"
export AI_SERVICES_ID="$AI_SERVICES_ID"
EOF

echo "✅ RBAC configuration saved to: $CONFIG_FILE"
echo ""

echo "========================================"
echo "Lab 2 Complete! 🎉"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Custom role created: $ROLE_NAME"
echo "  - Role Definition ID: $CUSTOM_ROLE_ID"
echo "  - Permissions documented in: $PERMISSIONS_FILE"
echo ""
echo "Next: Proceed to Lab 3 to set up Azure Policy for deployment governance"
