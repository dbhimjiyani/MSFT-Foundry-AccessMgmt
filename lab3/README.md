# Lab 3: Set up Azure Policy for DeepSeek Model Deployment

## Overview

This lab demonstrates how to implement Azure Policy to enforce governance over DeepSeek model deployments. The policy requires admin approval (via tags) before DeepSeek models can be deployed, while auditing all related activities for compliance.

## Prerequisites

- Completed Lab 1 (AI Foundry resources deployed)
- Completed Lab 2 (RBAC configured)
- Azure CLI logged in with sufficient permissions
- Owner or Contributor role on the subscription/resource group

## Concepts

### Azure Policy

Azure Policy helps enforce organizational standards and assess compliance at scale. It can:
- Prevent non-compliant resources from being created
- Audit existing resources for compliance
- Automatically remediate non-compliant resources

### Policy Components

1. **Policy Definition**: The rules and logic (what to enforce)
2. **Policy Assignment**: Where to apply the policy (scope)
3. **Policy Parameters**: Configurable values for flexibility

## Architecture

```
Azure Subscription
└── Resource Group
    ├── Policy 1: Approval Policy (Deny Effect)
    │   └── Blocks DeepSeek deployments without AdminApproved=true tag
    ├── Policy 2: Audit Policy (Audit Effect)
    │   └── Logs all DeepSeek model activities
    └── AI Resources
        └── Deployment attempts evaluated against policies
```

## Instructions

### 1. Review Policy Definitions

**Approval Policy** (`deepseek-approval-policy.json`):
- Enforces that DeepSeek deployments must have `AdminApproved=true` tag
- Uses `Deny` effect to block non-compliant deployments
- Configurable via parameters

**Audit Policy** (`deepseek-audit-policy.json`):
- Logs all DeepSeek model-related activities
- Uses `Audit` effect for monitoring
- Creates compliance reports

```bash
# Review the policies
cat deepseek-approval-policy.json
cat deepseek-audit-policy.json
```

### 2. Run the Policy Setup Script

```bash
chmod +x setup-policy.sh
./setup-policy.sh
```

This script will:
1. Create custom policy definitions
2. Assign policies to the resource group
3. Generate workflow documentation
4. Create testing guide

### 3. Verify Policy Assignment

```bash
# List all policy assignments
az policy assignment list \
  --resource-group rg-ai-foundry-demo \
  --output table

# View specific policy details
az policy assignment show \
  --name deepseek-approval-assignment \
  --resource-group rg-ai-foundry-demo
```

### 4. Test the Policy

**Note**: Policy enforcement may take 5-15 minutes to become active after assignment.

#### Test 1: Attempt deployment without approval (should fail)

```bash
# Create an endpoint first
az ml online-endpoint create \
  --name test-endpoint \
  --resource-group rg-ai-foundry-demo

# Attempt to deploy DeepSeek model without approval tag
az ml online-deployment create \
  --name deepseek-test \
  --endpoint-name test-endpoint \
  --model deepseek-coder:1 \
  --resource-group rg-ai-foundry-demo

# Expected: Policy violation error
```

#### Test 2: Deploy with admin approval (should succeed)

```bash
# Deploy with required approval tag
az ml online-deployment create \
  --name deepseek-approved \
  --endpoint-name test-endpoint \
  --model deepseek-coder:1 \
  --tags AdminApproved=true ApprovedBy=admin@company.com ApprovalDate=$(date +%Y-%m-%d) \
  --resource-group rg-ai-foundry-demo

# Expected: Successful deployment
```

### 5. Monitor Compliance

```bash
# View compliance state
az policy state list \
  --resource-group rg-ai-foundry-demo \
  --output table

# Check for non-compliant resources
az policy state list \
  --resource-group rg-ai-foundry-demo \
  --filter "complianceState eq 'NonCompliant'" \
  --output table

# View policy events in Activity Log
az monitor activity-log list \
  --resource-group rg-ai-foundry-demo \
  --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --query "[?contains(authorization.action, 'policy')]" \
  --output table
```

## What Gets Created

1. **Policy Definition: Approval Policy**
   - Name: `deepseek-deployment-approval`
   - Effect: Deny (blocks non-compliant deployments)
   - Scope: Resource Group

2. **Policy Definition: Audit Policy**
   - Name: `deepseek-deployment-audit`
   - Effect: Audit (logs all activities)
   - Scope: Resource Group

3. **Policy Assignments**
   - Approval policy assigned to resource group
   - Audit policy assigned to resource group

4. **Documentation**
   - `deployment-workflow.md`: Complete approval workflow
   - `testing-guide.md`: Test scenarios and validation

## Deployment Workflow

### For Non-Admin Users (with DeepSeek Model Reader role)

1. **Cannot deploy** - Role restricts deployment operations
2. **Can request** - Submit request to admin team
3. **Can use** - Access approved, deployed models

### For Admin Users

1. **Review request** - Evaluate justification
2. **Approve deployment** - Create with required tags:
   ```bash
   az ml online-deployment create \
     --name <deployment-name> \
     --tags AdminApproved=true ApprovedBy=<admin-email> ApprovalDate=<date> \
     ...
   ```
3. **Monitor** - Track compliance and audit logs

## Policy Parameters

The approval policy accepts these parameters:

- **effect**: `Deny` (default), `Audit`, or `Disabled`
- **requiredTagKey**: Tag key for approval (default: `AdminApproved`)
- **requiredTagValue**: Tag value for approval (default: `true`)

### Modifying Policy Parameters

```bash
az policy assignment update \
  --name deepseek-approval-assignment \
  --resource-group rg-ai-foundry-demo \
  --params '{
      "effect": {"value": "Audit"},
      "requiredTagKey": {"value": "ApprovedBy"},
      "requiredTagValue": {"value": "admin"}
  }'
```

## Integration with Lab 2 (RBAC)

This lab builds on Lab 2's RBAC configuration:

| Component | Lab 2 (RBAC) | Lab 3 (Policy) |
|-----------|--------------|----------------|
| **Purpose** | Control who can deploy | Control what can be deployed |
| **Mechanism** | Role assignments | Policy enforcement |
| **Scope** | User/group permissions | Resource compliance |
| **Combined Effect** | Non-admins can't deploy + Admins must tag deployments |

## Real-World Use Cases

### Use Case 1: Regulatory Compliance
- **Requirement**: All AI model deployments must be reviewed
- **Solution**: Policy ensures approval tag on all deployments
- **Benefit**: Audit trail for compliance officers

### Use Case 2: Cost Control
- **Requirement**: Prevent unauthorized expensive model deployments
- **Solution**: Policy blocks deployments without approval
- **Benefit**: Budget oversight and cost management

### Use Case 3: Security Review
- **Requirement**: Security team must review new models
- **Solution**: Approval workflow with security team sign-off
- **Benefit**: Reduced security risks

## Troubleshooting

### Issue: Policy not enforcing after assignment
**Solution**: Wait 5-15 minutes for policy to propagate. Use `--mode Indexed` if needed.

### Issue: Cannot create policy definition
**Solution**: Ensure you have Owner or Contributor role at subscription level

### Issue: Deployment denied with correct tag
**Solution**: Verify tag key and value exactly match policy parameters (case-sensitive)

### Issue: Audit logs not appearing
**Solution**: 
- Check Activity Log retention settings
- Ensure Log Analytics workspace is connected
- Wait a few minutes for logs to populate

## Best Practices

1. **Start with Audit Mode**
   - Begin with `effect: Audit` to understand impact
   - Switch to `effect: Deny` after validation

2. **Clear Tagging Standards**
   - Document required tags
   - Provide examples
   - Automate tag generation

3. **Regular Reviews**
   - Review policy compliance weekly
   - Adjust policies based on feedback
   - Update documentation

4. **Exemptions Management**
   - Document any policy exemptions
   - Set expiration dates
   - Regular exemption reviews

5. **Integration**
   - Integrate with CI/CD pipelines
   - Automate approval workflows
   - Connect to ticketing systems

## Viewing in Azure Portal

1. Navigate to **Azure Portal** → **Policy**
2. Select **Definitions** → Search for "DeepSeek"
3. Select **Assignments** → View resource group assignments
4. Select **Compliance** → View compliance reports

## Cost Implications

- Azure Policy has no additional cost
- Consider log storage costs for audit trails
- Factor in compliance management overhead

## Next Steps

After completing Lab 3, proceed to:
- **Lab 4**: Clean up all resources to avoid unnecessary charges

## Additional Resources

- [Azure Policy Documentation](https://docs.microsoft.com/en-us/azure/governance/policy/)
- [Policy Definition Structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure)
- [Policy Effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects)
- [Policy Compliance](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data)
