# Lab 2: Set up Role-Based Access Control (RBAC)

## Overview

This lab demonstrates how to create a custom Azure RBAC role that provides read-only access to DeepSeek models in AI Foundry. This allows non-admin users to view and use DeepSeek models without being able to deploy, modify, or delete them.

## Prerequisites

- Completed Lab 1 (AI Foundry resources must be deployed)
- Azure CLI logged in with sufficient permissions
- Owner or User Access Administrator role on the subscription/resource group

## Concepts

### Azure RBAC

Azure Role-Based Access Control (RBAC) allows you to grant specific permissions to users, groups, and applications at a certain scope. The scope can be a subscription, resource group, or individual resource.

### Custom Roles

While Azure provides built-in roles, custom roles allow fine-grained control over permissions. In this lab, we create a custom role specifically for DeepSeek model access.

## Architecture

```
Azure Subscription
└── Resource Group
    ├── AI Hub
    │   └── Custom Role: DeepSeek Model Reader
    │       ├── Permissions: Read models, endpoints
    │       └── Restrictions: No write, delete operations
    └── AI Project
        └── Role Assignment: Non-admin users → DeepSeek Model Reader
```

## Instructions

### 1. Review the Custom Role Definition

The custom role is defined in `deepseek-reader-role.json`:

```bash
cat deepseek-reader-role.json
```

Key permissions:
- **Actions**: Read operations on models, endpoints, and AI services
- **NotActions**: Write and delete operations are explicitly denied

### 2. Run the RBAC Setup Script

```bash
chmod +x setup-rbac.sh
./setup-rbac.sh
```

This script will:
1. Load configuration from Lab 1
2. Create the custom "DeepSeek Model Reader" role
3. Generate documentation and instructions
4. Save RBAC configuration for Lab 3

### 3. Assign the Role to Users

After creating the custom role, assign it to non-admin users:

```bash
# Option 1: Assign to a user at Resource Group level
az role assignment create \
  --assignee user@example.com \
  --role "DeepSeek Model Reader" \
  --resource-group rg-ai-foundry-demo

# Option 2: Assign to a group
az role assignment create \
  --assignee <group-object-id> \
  --role "DeepSeek Model Reader" \
  --resource-group rg-ai-foundry-demo

# Option 3: Assign at AI Project level only
az role assignment create \
  --assignee user@example.com \
  --role "DeepSeek Model Reader" \
  --scope <AI_PROJECT_ID>
```

### 4. Verify Role Assignment

```bash
# List all role assignments for a user
az role assignment list \
  --assignee user@example.com \
  --output table

# List all role assignments in the resource group
az role assignment list \
  --resource-group rg-ai-foundry-demo \
  --output table
```

### 5. Test the Role

To test the role, have a user with the "DeepSeek Model Reader" role attempt:

**✅ Should succeed:**
```bash
# View workspace
az ml workspace show --name <AI_PROJECT_NAME> --resource-group rg-ai-foundry-demo

# List models (if any are deployed)
az ml model list --workspace-name <AI_PROJECT_NAME> --resource-group rg-ai-foundry-demo
```

**❌ Should fail:**
```bash
# Attempt to create a deployment (should be denied)
az ml online-deployment create --name test-deployment --endpoint-name test ...
# Expected: Authorization error
```

## What Gets Created

1. **Custom Role Definition**: "DeepSeek Model Reader" with specific permissions
2. **Role Permissions Document**: Detailed summary of what users can and cannot do
3. **Configuration File**: RBAC settings for use in subsequent labs

## Role Permissions Summary

### Allowed Actions
- Read workspace information
- View models and model versions
- Read endpoint configurations
- View online endpoints
- Read AI Services accounts
- List API keys for inference

### Denied Actions
- Deploy new models
- Delete models
- Modify model configurations
- Create/delete endpoints
- Modify endpoint settings
- Create/delete deployments

## Security Best Practices

1. **Principle of Least Privilege**: Grant only the minimum permissions needed
2. **Scope Appropriately**: Assign roles at the narrowest scope (project > hub > resource group > subscription)
3. **Use Groups**: Assign roles to Azure AD groups rather than individual users
4. **Regular Audits**: Review role assignments periodically
5. **Monitor Access**: Use Azure Monitor to track who accesses what

## Troubleshooting

### Issue: "Insufficient privileges to complete the operation"
**Solution**: Ensure you have Owner or User Access Administrator role

### Issue: "Role definition already exists"
**Solution**: The script will update the existing role definition automatically

### Issue: "Cannot find user/group"
**Solution**: Verify the user email or group object ID is correct using:
```bash
az ad user show --id user@example.com
az ad group show --group <group-name>
```

## Real-World Scenarios

### Scenario 1: Data Science Team
- **Requirement**: Data scientists need to use DeepSeek models but shouldn't deploy to production
- **Solution**: Assign "DeepSeek Model Reader" role at project level

### Scenario 2: External Contractors
- **Requirement**: Contractors need temporary access to test models
- **Solution**: Create time-limited role assignments with expiration

### Scenario 3: Multi-Team Environment
- **Requirement**: Multiple teams with different access levels
- **Solution**: Create separate projects with different role assignments

## Cost Implications

Custom roles have no additional cost. However, consider:
- Regular audit of role assignments to remove unused permissions
- Automated role assignment management for scale

## Next Steps

After completing Lab 2, proceed to:
- **Lab 3**: Implement Azure Policy for deployment approval workflow
- **Lab 4**: Clean up resources

## Additional Resources

- [Azure Custom Roles Documentation](https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Azure RBAC Best Practices](https://docs.microsoft.com/en-us/azure/role-based-access-control/best-practices)
- [Azure ML RBAC](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-assign-roles)
