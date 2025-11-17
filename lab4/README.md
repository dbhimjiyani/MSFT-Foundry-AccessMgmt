# Lab 4: Resource Cleanup

## Overview

This lab provides a safe and thorough cleanup of all resources created in the previous labs. Running this cleanup is important to avoid unnecessary Azure charges.

## Prerequisites

- Completed at least Lab 1
- Azure CLI logged in
- Owner or Contributor role on the subscription/resource group

## What Gets Deleted

This cleanup script removes:

1. **Policy Assignments**
   - DeepSeek approval policy assignment
   - DeepSeek audit policy assignment

2. **Policy Definitions**
   - Custom approval policy
   - Custom audit policy

3. **Custom Role Definitions**
   - DeepSeek Model Reader role
   - All role assignments using this role

4. **Resource Group and All Contained Resources**
   - AI Hub
   - AI Project
   - Storage Account
   - Key Vault
   - AI Services (Cognitive Services)
   - All other resources in the group

5. **Local Configuration Files**
   - Environment configuration files
   - Generated documentation files

## Important Notes

⚠️ **Warning**: This operation is **irreversible**. All data in the deleted resources will be permanently lost.

✅ **Best Practice**: Export any important data, models, or configurations before running cleanup.

## Instructions

### 1. Review What Will Be Deleted

Before running cleanup, review your resources:

```bash
# List all resources in the resource group
az resource list --resource-group rg-ai-foundry-demo --output table

# List policy assignments
az policy assignment list --resource-group rg-ai-foundry-demo --output table

# List custom roles
az role definition list --custom-role-only true --output table
```

### 2. Run the Cleanup Script

```bash
chmod +x cleanup.sh
./cleanup.sh
```

The script will:
1. Load configuration from Lab 1 (if available)
2. Ask for confirmation before proceeding
3. Remove resources in the correct order
4. Generate a cleanup summary

### 3. Confirm Cleanup

```bash
# The script prompts for confirmation
Are you sure you want to continue? (yes/no): yes
```

### 4. Verify Cleanup Completed

Wait 5-10 minutes for resource group deletion to complete, then verify:

```bash
# Check if resource group still exists (should return error when deleted)
az group show --name rg-ai-foundry-demo

# Verify policy definitions are removed
az policy definition list --query "[?contains(name, 'deepseek')]" --output table

# Verify custom role is removed
az role definition list --custom-role-only true --query "[?contains(roleName, 'DeepSeek')]" --output table
```

## Manual Cleanup (If Script Fails)

If the automated script fails, you can manually clean up resources:

### 1. Remove Policy Assignments

```bash
az policy assignment delete \
  --name deepseek-approval-assignment \
  --resource-group rg-ai-foundry-demo

az policy assignment delete \
  --name deepseek-audit-assignment \
  --resource-group rg-ai-foundry-demo
```

### 2. Delete Policy Definitions

```bash
az policy definition delete \
  --name deepseek-deployment-approval

az policy definition delete \
  --name deepseek-deployment-audit
```

### 3. Remove Custom Role

```bash
# First, remove any role assignments
az role assignment list --role "DeepSeek Model Reader" --query "[].id" -o tsv | \
  xargs -I {} az role assignment delete --ids {}

# Then delete the role definition
az role definition delete --name "DeepSeek Model Reader"
```

### 4. Delete Resource Group

```bash
az group delete --name rg-ai-foundry-demo --yes --no-wait
```

## Cleanup Order

The script follows this order to avoid dependency issues:

1. **Policy Assignments** (must be removed before policy definitions)
2. **Policy Definitions** (must be removed before resource deletion)
3. **Role Assignments** (must be removed before role definitions)
4. **Role Definitions** (must be removed before resources that use them)
5. **Resource Group** (contains all Azure resources)
6. **Local Files** (configuration and generated files)

## Partial Cleanup

If you want to keep some resources, you can selectively delete:

### Keep Resources, Remove Only Policies

```bash
# Remove just the policy assignments
az policy assignment delete --name deepseek-approval-assignment --resource-group rg-ai-foundry-demo
az policy assignment delete --name deepseek-audit-assignment --resource-group rg-ai-foundry-demo

# Remove policy definitions
az policy definition delete --name deepseek-deployment-approval
az policy definition delete --name deepseek-deployment-audit
```

### Keep Resources, Remove Only RBAC

```bash
# Remove role assignments
az role assignment list --role "DeepSeek Model Reader" --query "[].id" -o tsv | \
  xargs -I {} az role assignment delete --ids {}

# Remove role definition
az role definition delete --name "DeepSeek Model Reader"
```

## Troubleshooting

### Issue: "Resource group deletion failed"
**Solution**: 
- Some resources may have locks or dependencies
- Delete individual resources first, then the resource group
- Check for resource locks: `az lock list --resource-group rg-ai-foundry-demo`

### Issue: "Cannot delete policy - still assigned"
**Solution**: Remove policy assignments first, then delete policy definitions

### Issue: "Cannot delete role - still assigned"
**Solution**: Remove all role assignments first, then delete the role definition

### Issue: "Permission denied"
**Solution**: Ensure you have Owner or Contributor role on the subscription

## Cost Verification

After cleanup, verify no charges are accumulating:

1. **Check Azure Portal**
   - Navigate to Cost Management + Billing
   - View cost analysis for your subscription
   - Verify no charges from deleted resource group

2. **Set Up Cost Alert**
   ```bash
   az consumption budget create \
     --budget-name "lab-budget" \
     --amount 0 \
     --time-grain Monthly \
     --start-date $(date +%Y-%m-01) \
     --end-date $(date -d "+1 year" +%Y-%m-01)
   ```

## Soft Delete Protection

Some resources have soft-delete protection:

### Key Vault
Key Vaults are soft-deleted by default and retained for 90 days:

```bash
# List deleted key vaults
az keyvault list-deleted

# Permanently delete a soft-deleted key vault
az keyvault purge --name <key-vault-name>
```

### Storage Account
Storage accounts may have soft-delete for blobs:

```bash
# Check soft-delete status
az storage account blob-service-properties show \
  --account-name <storage-account-name> \
  --query deleteRetentionPolicy
```

## Cleanup Checklist

Use this checklist to verify complete cleanup:

- [ ] Policy assignments removed
- [ ] Policy definitions deleted
- [ ] Custom role assignments removed
- [ ] Custom role definition deleted
- [ ] Resource group deletion initiated
- [ ] Wait 5-10 minutes for deletion to complete
- [ ] Verify resource group no longer exists
- [ ] Check no remaining costs in Cost Management
- [ ] Purge soft-deleted resources (if needed)
- [ ] Remove local configuration files

## Best Practices

1. **Always Clean Up Test Resources**
   - Run cleanup immediately after completing labs
   - Don't leave test resources running overnight

2. **Verify Before Deleting**
   - Double-check you're deleting the correct resources
   - Export any data you want to keep

3. **Use Resource Tags**
   - Tag resources with expiration dates
   - Set up automated cleanup with Azure Automation

4. **Monitor Costs**
   - Set up cost alerts
   - Review billing regularly

## Alternative: Terraform Destroy

If you used Terraform to create resources:

```bash
terraform destroy -auto-approve
```

## Re-running Labs

To re-run the labs after cleanup:

1. Run Lab 1 setup script again
2. Run Lab 2 RBAC setup
3. Run Lab 3 policy setup
4. Run Lab 4 cleanup when done

All scripts are designed to be re-runnable.

## Support

If you encounter issues during cleanup:

1. Check Azure Activity Log for error details
2. Review Azure Policy compliance state
3. Contact your Azure administrator
4. Open an issue in the repository

## Summary

This lab completes the AI Foundry Access Management workshop. You've learned:

- **Lab 1**: How to set up AI Foundry resources
- **Lab 2**: How to configure role-based access control
- **Lab 3**: How to implement policy-based governance
- **Lab 4**: How to properly clean up resources

Thank you for completing the labs! 🎉

## Additional Resources

- [Azure Resource Cleanup Best Practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Cost Management Documentation](https://docs.microsoft.com/en-us/azure/cost-management-billing/)
- [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)
