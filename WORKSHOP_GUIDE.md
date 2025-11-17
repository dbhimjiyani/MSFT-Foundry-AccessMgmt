# Azure AI Foundry Access Management - Workshop Guide

## Welcome! 👋

This workshop provides hands-on experience with Azure AI Foundry access management, demonstrating how to secure AI model deployments using Azure RBAC and Azure Policy.

## 🎯 What You'll Learn

By completing these labs, you'll gain practical experience with:

1. **Infrastructure as Code**: Automate Azure AI Foundry deployment
2. **Access Control**: Implement role-based access control (RBAC)
3. **Governance**: Enforce policies for compliance and approval workflows
4. **Security Best Practices**: Layer security controls for robust protection

## 📖 Workshop Structure

### Duration: ~1 hour
- Lab 1: 15 minutes
- Lab 2: 10 minutes
- Lab 3: 15 minutes
- Lab 4: 5 minutes
- Buffer: 15 minutes for questions/troubleshooting

### Difficulty: Intermediate
- Requires: Basic Azure knowledge
- Requires: Familiarity with CLI/terminal
- Requires: Understanding of cloud security concepts

## 🚦 Getting Started

### Step 1: Prerequisites Check

Before you begin, ensure you have:

```bash
# 1. Azure CLI installed
az --version

# 2. Logged in to Azure
az login

# 3. Azure ML extension installed
az extension add --name ml --upgrade

# 4. Verify subscription access
az account show
```

### Step 2: Clone Repository

```bash
git clone https://github.com/dbhimjiyani/MSFT-Foundry-AccessMgmt.git
cd MSFT-Foundry-AccessMgmt
```

### Step 3: Review Architecture

Before running any commands, review the [main README](README.md) to understand the overall architecture and security model.

## 📝 Lab Sequence

### Lab 1: Foundation
**Purpose**: Set up Azure AI Foundry infrastructure

Start here: [lab1/README.md](lab1/README.md)

```bash
cd lab1
./setup-ai-foundry.sh
```

**What you'll learn**:
- Azure AI Foundry resource dependencies
- Resource naming conventions
- Configuration management

---

### Lab 2: Access Control
**Purpose**: Implement role-based access control

Start here: [lab2/README.md](lab2/README.md)

```bash
cd lab2
./setup-rbac.sh
```

**What you'll learn**:
- Custom Azure role creation
- Permission granularity
- Role assignment scopes
- Principle of least privilege

---

### Lab 3: Governance
**Purpose**: Enforce deployment policies

Start here: [lab3/README.md](lab3/README.md)

```bash
cd lab3
./setup-policy.sh
```

**What you'll learn**:
- Azure Policy definition
- Policy assignment and scope
- Compliance monitoring
- Approval workflows

---

### Lab 4: Cleanup
**Purpose**: Remove all resources safely

Start here: [lab4/README.md](lab4/README.md)

```bash
cd lab4
./cleanup.sh
```

**What you'll learn**:
- Resource dependency management
- Safe deletion procedures
- Cost optimization

## 🎓 Key Concepts Explained

### RBAC vs Policy: What's the Difference?

| Aspect | RBAC | Azure Policy |
|--------|------|--------------|
| **Controls** | WHO can do actions | WHAT actions can be done |
| **Focus** | Identity-based | Resource-based |
| **Example** | User X can deploy models | Models must have approval tag |
| **Evaluation** | At permission check | At resource creation/update |

### Layered Security Model

```
┌─────────────────────────────────────┐
│   Azure Active Directory (AAD)      │  Authentication
├─────────────────────────────────────┤
│   RBAC (Role Assignments)           │  Authorization
├─────────────────────────────────────┤
│   Azure Policy                       │  Governance
├─────────────────────────────────────┤
│   Resource Locks                     │  Protection
├─────────────────────────────────────┤
│   Audit Logs                         │  Monitoring
└─────────────────────────────────────┘
```

### DeepSeek Model Scenario

These labs use **DeepSeek models** as an example to demonstrate:
- How to restrict access to specific AI models
- How to enforce approval workflows
- How to maintain audit trails

**Note**: The same patterns apply to any AI model (GPT, LLaMA, Mistral, etc.)

## 🔧 Customization Guide

### Use Your Own Model Names

Edit the policy files to target different models:

```json
// In lab3/deepseek-approval-policy.json
{
  "field": "name",
  "contains": "your-model-name"  // Change "deepseek" to your model
}
```

### Change Resource Names

Set environment variables before running Lab 1:

```bash
export RESOURCE_GROUP_NAME="my-custom-rg"
export LOCATION="westus2"
./setup-ai-foundry.sh
```

### Modify Role Permissions

Edit `lab2/deepseek-reader-role.json` to add/remove permissions:

```json
{
  "Actions": [
    "Microsoft.MachineLearningServices/workspaces/read",
    // Add your custom actions here
  ]
}
```

## 💡 Tips & Best Practices

### 💰 Cost Management
1. Complete all labs in one session
2. Run cleanup immediately after
3. Use cost alerts: `az consumption budget create`
4. Tag resources for tracking

### 🔒 Security
1. Never commit secrets to git
2. Use Key Vault for sensitive data
3. Regularly review role assignments
4. Monitor compliance reports

### 🐛 Debugging
1. Check Activity Logs in Azure Portal
2. Use `--debug` flag with Azure CLI
3. Verify policy propagation (wait 5-15 min)
4. Review script output carefully

### 📊 Monitoring
1. Enable Log Analytics workspace
2. Set up Azure Monitor alerts
3. Review compliance dashboards
4. Track policy violations

## 🎯 Workshop Scenarios

### Scenario 1: Enterprise AI Governance
**Context**: Large organization with multiple teams using AI

**Implementation**:
- Different RBAC roles for each team
- Policy requiring department approval
- Audit trail for compliance team

### Scenario 2: Startup with External Contractors
**Context**: Small team with temporary external help

**Implementation**:
- Time-limited role assignments
- Strict read-only access for contractors
- Owner approval for all deployments

### Scenario 3: Regulated Industry (Healthcare/Finance)
**Context**: Strict compliance requirements

**Implementation**:
- Multi-level approval workflow
- Comprehensive audit logging
- Regular compliance reviews
- Data residency policies

## 🔍 Verification Checklist

After completing all labs, verify:

- [ ] Lab 1: Resource group created with all resources
- [ ] Lab 1: Configuration file generated
- [ ] Lab 2: Custom role definition exists
- [ ] Lab 2: Can assign role to users
- [ ] Lab 3: Both policies created and assigned
- [ ] Lab 3: Policy blocks unapproved deployments
- [ ] Lab 3: Policy allows approved deployments
- [ ] Lab 4: All resources cleaned up
- [ ] Lab 4: No unexpected charges appear

## 📚 Further Learning

### Microsoft Learn Paths
- [Azure AI Fundamentals](https://learn.microsoft.com/training/paths/get-started-with-artificial-intelligence-on-azure/)
- [Azure Security](https://learn.microsoft.com/training/paths/manage-security-azure/)
- [Azure Governance](https://learn.microsoft.com/training/paths/cloud-adoption-framework/)

### Related Topics
- Azure Managed Identity
- Azure Key Vault integration
- Azure DevOps CI/CD for AI
- MLOps best practices

## 🆘 Getting Help

### Common Issues

1. **Azure CLI errors**: Run `az upgrade` to update
2. **Permission denied**: Check subscription role
3. **Policy not working**: Wait 15 minutes for propagation
4. **Script fails**: Check Prerequisites section

### Resources

- [GitHub Issues](https://github.com/dbhimjiyani/MSFT-Foundry-AccessMgmt/issues)
- [Azure Support](https://azure.microsoft.com/support/)
- [Stack Overflow - Azure](https://stackoverflow.com/questions/tagged/azure)

## 🎉 Completion

### What's Next?

After completing the workshop:

1. **Apply to Your Environment**: Adapt these patterns to your use case
2. **Expand Coverage**: Add policies for other resources
3. **Automate More**: Integrate with CI/CD pipelines
4. **Share Knowledge**: Train your team on these patterns

### Feedback

We'd love to hear from you! Please provide feedback:
- Open an issue with suggestions
- Submit a PR with improvements
- Share your success stories

## 📄 License & Disclaimer

This workshop is provided for educational purposes. Always:
- Follow your organization's policies
- Test in non-production environments first
- Review costs and security implications
- Consult your IT/Security teams

---

**Happy Learning! 🚀**

For questions or issues, please open a GitHub issue or contact the maintainers.
