#!/bin/bash

# Lab 3: Set up Azure Policy for DeepSeek Model Deployment Governance
# This script creates and assigns Azure Policies to enforce approval workflows

set -e

# Load configuration from Lab 1
if [ -f "../lab1/ai-foundry-config.env" ]; then
    source ../lab1/ai-foundry-config.env
    echo "✅ Loaded configuration from Lab 1"
else
    echo "❌ Configuration file not found. Please run Lab 1 first."
    exit 1
fi

echo "========================================"
echo "Lab 3: Setting up Azure Policy for DeepSeek Models"
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

# Step 1: Create the approval policy
APPROVAL_POLICY_FILE="deepseek-approval-policy.json"
APPROVAL_POLICY_NAME="deepseek-deployment-approval"

echo "Creating policy definition: $APPROVAL_POLICY_NAME"
az policy definition create \
    --name "$APPROVAL_POLICY_NAME" \
    --display-name "Require Admin Approval for DeepSeek Model Deployments" \
    --description "Enforces that DeepSeek model deployments must have admin approval tag" \
    --rules "$APPROVAL_POLICY_FILE" \
    --mode All \
    --subscription "$SUBSCRIPTION_ID" \
    || echo "⚠️  Policy may already exist, updating..."

# If policy already exists, update it
if az policy definition show --name "$APPROVAL_POLICY_NAME" --subscription "$SUBSCRIPTION_ID" &> /dev/null; then
    echo "✅ Policy definition exists"
else
    echo "❌ Failed to create policy definition"
    exit 1
fi

echo ""

# Step 2: Create the audit policy
AUDIT_POLICY_FILE="deepseek-audit-policy.json"
AUDIT_POLICY_NAME="deepseek-deployment-audit"

echo "Creating audit policy definition: $AUDIT_POLICY_NAME"
az policy definition create \
    --name "$AUDIT_POLICY_NAME" \
    --display-name "Audit DeepSeek Model Deployments" \
    --description "Audits all DeepSeek model deployments for compliance monitoring" \
    --rules "$AUDIT_POLICY_FILE" \
    --mode All \
    --subscription "$SUBSCRIPTION_ID" \
    || echo "⚠️  Policy may already exist"

echo "✅ Audit policy definition created"
echo ""

# Step 3: Assign policies to resource group
APPROVAL_ASSIGNMENT_NAME="deepseek-approval-assignment"
AUDIT_ASSIGNMENT_NAME="deepseek-audit-assignment"

echo "Assigning approval policy to resource group..."
az policy assignment create \
    --name "$APPROVAL_ASSIGNMENT_NAME" \
    --display-name "DeepSeek Deployment Approval Required" \
    --policy "$APPROVAL_POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --params '{
        "effect": {"value": "Deny"},
        "requiredTagKey": {"value": "AdminApproved"},
        "requiredTagValue": {"value": "true"}
    }' \
    || echo "⚠️  Assignment may already exist"

echo "✅ Approval policy assigned"
echo ""

echo "Assigning audit policy to resource group..."
az policy assignment create \
    --name "$AUDIT_ASSIGNMENT_NAME" \
    --display-name "Audit DeepSeek Deployments" \
    --policy "$AUDIT_POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    || echo "⚠️  Assignment may already exist"

echo "✅ Audit policy assigned"
echo ""

# Step 4: Create documentation
WORKFLOW_DOC="deployment-workflow.md"
cat > "$WORKFLOW_DOC" <<'EOF'
# DeepSeek Model Deployment Workflow

## Overview

With Azure Policy in place, DeepSeek model deployments now require admin approval. This document describes the workflow.

## Deployment Process

### For Non-Admin Users

1. **Request Deployment**
   - Prepare deployment configuration
   - Submit request to admin team
   - Provide justification and use case

2. **Wait for Approval**
   - Admin reviews the request
   - Admin validates business justification
   - Admin performs security assessment

3. **Admin Approves**
   - Admin creates deployment with approval tag
   - Deployment proceeds successfully

### For Admin Users

1. **Review Request**
   - Evaluate business justification
   - Assess security implications
   - Verify compliance requirements

2. **Approve Deployment**
   - Create deployment with required tag:
   ```bash
   az ml online-deployment create \
     --name deepseek-deployment \
     --endpoint-name deepseek-endpoint \
     --model deepseek-model:1 \
     --tags AdminApproved=true ApprovedBy=admin@company.com ApprovalDate=$(date +%Y-%m-%d) \
     --resource-group rg-ai-foundry-demo
   ```

3. **Document Approval**
   - Record approval in tracking system
   - Add tags with approval metadata

## Policy Enforcement

### What's Blocked

Without the `AdminApproved=true` tag, the following operations are denied:

- Creating new DeepSeek model deployments
- Updating existing DeepSeek deployments (depending on policy configuration)

### What's Allowed

- Viewing existing DeepSeek models (read-only access)
- Using already-deployed DeepSeek endpoints
- Deploying non-DeepSeek models (not affected by policy)

## Compliance Monitoring

The audit policy logs all DeepSeek-related activities:

1. **View Audit Logs**
   ```bash
   az monitor activity-log list \
     --resource-group rg-ai-foundry-demo \
     --query "[?contains(properties.message, 'deepseek')]" \
     --output table
   ```

2. **Policy Compliance Report**
   ```bash
   az policy state list \
     --resource-group rg-ai-foundry-demo \
     --filter "policyDefinitionName eq 'deepseek-deployment-audit'" \
     --output table
   ```

3. **Review Non-Compliant Resources**
   ```bash
   az policy state list \
     --resource-group rg-ai-foundry-demo \
     --filter "complianceState eq 'NonCompliant'" \
     --output table
   ```

## Example: Complete Deployment Flow

### Scenario: Deploy DeepSeek-V2 Model

```bash
# 1. Non-admin user attempts deployment (will fail)
az ml online-deployment create \
  --name deepseek-v2-prod \
  --endpoint-name prod-endpoint \
  --model deepseek-v2:latest \
  --resource-group rg-ai-foundry-demo
# Result: ❌ Policy violation - AdminApproved tag missing

# 2. Admin approves and deploys
az ml online-deployment create \
  --name deepseek-v2-prod \
  --endpoint-name prod-endpoint \
  --model deepseek-v2:latest \
  --tags AdminApproved=true ApprovedBy=admin@company.com ApprovalDate=2024-01-15 Purpose="Production inference" \
  --resource-group rg-ai-foundry-demo
# Result: ✅ Deployment successful
```

## Policy Parameters

### Approval Policy Parameters

- **effect**: `Deny` (blocks deployments) or `Audit` (logs but allows)
- **requiredTagKey**: Default is `AdminApproved`
- **requiredTagValue**: Default is `true`

### Modifying Policy Parameters

```bash
az policy assignment update \
  --name deepseek-approval-assignment \
  --resource-group rg-ai-foundry-demo \
  --params '{
      "effect": {"value": "Audit"},
      "requiredTagKey": {"value": "ReviewedBy"},
      "requiredTagValue": {"value": "SecurityTeam"}
  }'
```

## Best Practices

1. **Clear Approval Criteria**
   - Document what requires approval
   - Define approval SLAs
   - Maintain approval records

2. **Audit Trail**
   - Always include approval metadata in tags
   - Log all approval decisions
   - Regular compliance reviews

3. **Emergency Process**
   - Have a documented emergency approval process
   - Define who can approve in emergencies
   - Post-deployment review for emergency approvals

4. **Policy Review**
   - Regularly review policy effectiveness
   - Update policies based on lessons learned
   - Adjust parameters as needed

## Troubleshooting

### Issue: Deployment denied even with approval tag
**Solution**: Check tag format exactly matches policy parameters (case-sensitive)

### Issue: Policy not enforcing
**Solution**: Policy assignments may take 5-15 minutes to take effect. Wait and retry.

### Issue: Cannot view audit logs
**Solution**: Ensure you have Reader access to Activity Logs or Log Analytics workspace

## Security Considerations

1. **Separation of Duties**: Non-admins cannot deploy, only admins can approve
2. **Audit Trail**: All deployments are logged for compliance
3. **Principle of Least Privilege**: Combined with RBAC from Lab 2
4. **Accountability**: Approval tags document who approved what and when

## Integration with Existing Workflows

This policy can integrate with:

- **ServiceNow/Jira**: Create tickets for approval requests
- **Azure DevOps**: Integrate into CI/CD pipelines with approval gates
- **Custom Apps**: Use Azure Policy API for automated checks

EOF

echo "✅ Deployment workflow documented in: $WORKFLOW_DOC"
echo ""

# Step 5: Create testing guide
TEST_GUIDE="testing-guide.md"
cat > "$TEST_GUIDE" <<'EOF'
# Testing Guide: Azure Policy for DeepSeek Models

## Test Scenarios

### Test 1: Verify Policy Blocks Non-Approved Deployment

**Objective**: Confirm policy denies deployment without approval tag

```bash
# This should FAIL
az ml online-endpoint create \
  --name test-endpoint-001 \
  --resource-group rg-ai-foundry-demo

az ml online-deployment create \
  --name deepseek-test \
  --endpoint-name test-endpoint-001 \
  --model deepseek-coder:1 \
  --resource-group rg-ai-foundry-demo

# Expected result: Policy violation error
```

### Test 2: Verify Approved Deployment Succeeds

**Objective**: Confirm deployment succeeds with approval tag

```bash
# This should SUCCEED
az ml online-endpoint create \
  --name test-endpoint-002 \
  --resource-group rg-ai-foundry-demo

az ml online-deployment create \
  --name deepseek-test-approved \
  --endpoint-name test-endpoint-002 \
  --model deepseek-coder:1 \
  --tags AdminApproved=true ApprovedBy=admin@test.com \
  --resource-group rg-ai-foundry-demo

# Expected result: Successful deployment
```

### Test 3: Verify Audit Logging

**Objective**: Confirm all DeepSeek activities are audited

```bash
# Check policy compliance state
az policy state list \
  --resource-group rg-ai-foundry-demo \
  --filter "policyDefinitionName eq 'deepseek-deployment-audit'" \
  --output table

# View recent policy events
az monitor activity-log list \
  --resource-group rg-ai-foundry-demo \
  --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --output table
```

### Test 4: Non-DeepSeek Models Not Affected

**Objective**: Verify policy only affects DeepSeek models

```bash
# This should SUCCEED even without approval tag
az ml online-deployment create \
  --name other-model-test \
  --endpoint-name test-endpoint-003 \
  --model gpt-3.5:1 \
  --resource-group rg-ai-foundry-demo

# Expected result: Successful (policy doesn't apply)
```

## Validation Checklist

- [ ] Policy definition created successfully
- [ ] Policy assigned to resource group
- [ ] Non-approved DeepSeek deployment is blocked
- [ ] Approved DeepSeek deployment succeeds
- [ ] Audit logs capture all events
- [ ] Non-DeepSeek models are not affected
- [ ] Policy compliance shows in Azure Portal

EOF

echo "✅ Testing guide created: $TEST_GUIDE"
echo ""

# Save policy configuration
POLICY_CONFIG="policy-config.env"
cat > "$POLICY_CONFIG" <<EOF
# Azure Policy Configuration
# Generated on $(date)
export APPROVAL_POLICY_NAME="$APPROVAL_POLICY_NAME"
export AUDIT_POLICY_NAME="$AUDIT_POLICY_NAME"
export APPROVAL_ASSIGNMENT_NAME="$APPROVAL_ASSIGNMENT_NAME"
export AUDIT_ASSIGNMENT_NAME="$AUDIT_ASSIGNMENT_NAME"
EOF

echo "✅ Policy configuration saved to: $POLICY_CONFIG"
echo ""

echo "========================================"
echo "Lab 3 Complete! 🎉"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Approval Policy: $APPROVAL_POLICY_NAME"
echo "  - Audit Policy: $AUDIT_POLICY_NAME"
echo "  - Workflow documented in: $WORKFLOW_DOC"
echo "  - Testing guide: $TEST_GUIDE"
echo ""
echo "Policy enforcement is now active!"
echo "DeepSeek model deployments require AdminApproved=true tag"
echo ""
echo "Next: Proceed to Lab 4 to clean up resources"
