# Quick Start Guide

Get started with Azure AI Foundry Access Management labs in 5 minutes!

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] Azure subscription with Owner or Contributor role
- [ ] Azure CLI installed: `az --version`
- [ ] Logged in to Azure: `az login`
- [ ] Azure ML extension: `az extension add --name ml --upgrade`
- [ ] 1 hour of time to complete all labs
- [ ] Willingness to incur minimal Azure charges (~$1-2 for full workshop)

## 5-Minute Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/dbhimjiyani/MSFT-Foundry-AccessMgmt.git
cd MSFT-Foundry-AccessMgmt

# 2. Verify prerequisites
az account show
az extension show --name ml

# 3. Run Lab 1 (AI Foundry Setup)
cd lab1
./setup-ai-foundry.sh

# 4. Run Lab 2 (RBAC Setup)
cd ../lab2
./setup-rbac.sh

# 5. Run Lab 3 (Policy Setup)
cd ../lab3
./setup-policy.sh

# 6. IMPORTANT: Clean up to avoid charges
cd ../lab4
./cleanup.sh
```

## Expected Timeline

| Lab | Duration | Description |
|-----|----------|-------------|
| Lab 1 | 15 min | Set up AI Foundry resources |
| Lab 2 | 10 min | Configure RBAC roles |
| Lab 3 | 15 min | Implement Azure Policy |
| Lab 4 | 5 min | Clean up resources |
| **Total** | **45 min** | Complete workshop |

## What You'll Build

```
Azure Environment
├── AI Foundry Hub & Project
├── Custom RBAC Role: "DeepSeek Model Reader"
├── Azure Policy: Deployment approval enforcement
└── Azure Policy: Audit logging
```

## Common Issues & Quick Fixes

### Issue 1: "az ml command not found"
```bash
az extension add --name ml --upgrade
```

### Issue 2: "Permission denied"
```bash
# Check your role
az role assignment list --assignee $(az account show --query user.name -o tsv) \
  --query "[?roleDefinitionName=='Owner' || roleDefinitionName=='Contributor']" \
  --output table
```

### Issue 3: "Resource already exists"
```bash
# The scripts use random names to avoid conflicts
# If needed, set custom names:
export RESOURCE_GROUP_NAME="my-unique-rg"
./setup-ai-foundry.sh
```

## Next Steps After Quick Start

1. **Review the output** from each script
2. **Read the detailed READMEs** in each lab directory
3. **Check the Azure Portal** to see created resources
4. **Review ARCHITECTURE.md** for detailed diagrams
5. **Read WORKSHOP_GUIDE.md** for deeper understanding

## Alternative: Detailed Learning Path

If you prefer a slower, more thorough approach:

1. Read [README.md](README.md) - Overview
2. Read [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture diagrams
3. Read [WORKSHOP_GUIDE.md](WORKSHOP_GUIDE.md) - Detailed guide
4. Complete Lab 1 with [lab1/README.md](lab1/README.md)
5. Complete Lab 2 with [lab2/README.md](lab2/README.md)
6. Complete Lab 3 with [lab3/README.md](lab3/README.md)
7. Complete Lab 4 with [lab4/README.md](lab4/README.md)

## Cost Estimate

Running all labs once:
- Duration: ~45 minutes
- Estimated cost: **$0.75 - $1.50**
- With cleanup: **$0.00 ongoing**
- Without cleanup: **$12-24 per day** ⚠️

**Always run Lab 4 cleanup!**

## Getting Help

- **Documentation**: Check README files in each lab directory
- **Issues**: [GitHub Issues](https://github.com/dbhimjiyani/MSFT-Foundry-AccessMgmt/issues)
- **Azure Support**: [Azure Portal Support](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)

## Verification Commands

After completing all labs, verify:

```bash
# Check resources (should exist after Labs 1-3)
az resource list --resource-group rg-ai-foundry-demo --output table

# Check custom role
az role definition list --name "DeepSeek Model Reader" --output table

# Check policies
az policy assignment list --resource-group rg-ai-foundry-demo --output table

# After Lab 4, verify cleanup (should fail with error)
az group show --name rg-ai-foundry-demo
# Expected: ResourceGroupNotFound error
```

## Workshop Facilitation

If you're running this as a workshop:

1. **Pre-workshop**: 
   - Test all scripts in your environment
   - Prepare an Azure subscription for attendees
   - Review [WORKSHOP_GUIDE.md](WORKSHOP_GUIDE.md)

2. **During workshop**:
   - Start with architecture overview
   - Live demo Lab 1
   - Have attendees complete Labs 2-3
   - Discuss security implications

3. **Post-workshop**:
   - Ensure all attendees run Lab 4 cleanup
   - Share additional resources
   - Collect feedback

## Key Learning Outcomes

After completing these labs, you will:

- ✅ Understand Azure AI Foundry architecture
- ✅ Create custom RBAC roles for fine-grained access
- ✅ Implement Azure Policy for governance
- ✅ Build approval workflows for AI model deployment
- ✅ Monitor and audit AI resource usage
- ✅ Apply security best practices to AI workloads

## Security Reminder

🔒 **Important Security Notes**:
- Never commit secrets to Git
- Use Key Vault for sensitive data
- Review role assignments regularly
- Monitor policy compliance
- Keep audit logs for compliance

## Ready to Start?

Choose your path:

**Fast Track** (45 min):
```bash
cd MSFT-Foundry-AccessMgmt
./lab1/setup-ai-foundry.sh && \
./lab2/setup-rbac.sh && \
./lab3/setup-policy.sh && \
./lab4/cleanup.sh
```

**Learning Track** (2 hours):
Read all documentation, then run each lab individually

---

**Questions?** Open an issue or check the detailed documentation.

**Ready?** Let's get started! 🚀
