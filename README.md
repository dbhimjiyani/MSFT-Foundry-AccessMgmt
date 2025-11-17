# Azure AI Foundry Access Management Labs

This repository contains hands-on labs to demonstrate access management and governance for Azure AI Foundry using Azure Role-Based Access Control (RBAC) and Azure Policy.

## 🎯 Overview

Learn how to secure AI model deployments using Azure's governance tools. These labs specifically focus on controlling access to DeepSeek models through a combination of RBAC and Azure Policy.

## 📚 Labs

### [Lab 1: Set up AI Foundry Resource via Azure CLI](lab1/README.md)
Create an Azure AI Foundry environment with all required dependencies including:
- Resource Group
- Storage Account
- Key Vault
- AI Services (Cognitive Services)
- AI Hub and AI Project

**Duration**: ~15 minutes  
**Prerequisites**: Azure CLI, Azure subscription

### [Lab 2: Set up Role-Based Access Control (RBAC)](lab2/README.md)
Create a custom Azure role that provides read-only access to DeepSeek models:
- Custom role: "DeepSeek Model Reader"
- Permissions for viewing and using models
- Restrictions on deployment and deletion operations

**Duration**: ~10 minutes  
**Prerequisites**: Completed Lab 1

### [Lab 3: Set up Azure Policy for Deployment Governance](lab3/README.md)
Implement Azure Policies to enforce approval workflows for DeepSeek model deployments:
- Approval policy (requires AdminApproved tag)
- Audit policy (logs all DeepSeek activities)
- Compliance monitoring and reporting

**Duration**: ~15 minutes  
**Prerequisites**: Completed Labs 1 and 2

### [Lab 4: Resource Cleanup](lab4/README.md)
Safely remove all resources created in previous labs:
- Delete policy assignments and definitions
- Remove custom role definitions
- Delete resource group and all resources
- Clean up local configuration files

**Duration**: ~5 minutes (plus 5-10 minutes for async deletion)  
**Prerequisites**: Completed at least Lab 1

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/dbhimjiyani/MSFT-Foundry-AccessMgmt.git
cd MSFT-Foundry-AccessMgmt

# Login to Azure
az login

# Install Azure ML extension
az extension add --name ml --upgrade

# Run Lab 1
cd lab1
chmod +x setup-ai-foundry.sh
./setup-ai-foundry.sh

# Run Lab 2
cd ../lab2
chmod +x setup-rbac.sh
./setup-rbac.sh

# Run Lab 3
cd ../lab3
chmod +x setup-policy.sh
./setup-policy.sh

# Clean up (when done)
cd ../lab4
chmod +x cleanup.sh
./cleanup.sh
```

## 🏗️ Architecture

```
Azure Subscription
└── Resource Group (rg-ai-foundry-demo)
    ├── Storage Account
    ├── Key Vault
    ├── AI Services
    ├── AI Hub (ML Workspace)
    ├── AI Project (ML Workspace)
    │
    ├── Custom Role: "DeepSeek Model Reader"
    │   ├── Read permissions: ✅
    │   └── Write/Delete permissions: ❌
    │
    └── Azure Policies
        ├── Approval Policy (Deny without AdminApproved tag)
        └── Audit Policy (Log all activities)
```

## 🎓 Learning Objectives

After completing these labs, you will understand:

1. **Azure AI Foundry Setup**
   - How to provision AI Foundry resources using Azure CLI
   - Resource dependencies and relationships
   - Best practices for AI resource organization

2. **Role-Based Access Control (RBAC)**
   - Creating custom Azure roles
   - Fine-grained permission management
   - Principle of least privilege
   - Role assignment at different scopes

3. **Azure Policy for Governance**
   - Writing custom policy definitions
   - Policy assignment and enforcement
   - Compliance monitoring and reporting
   - Approval workflows using tags

4. **Combined Security Model**
   - Layered security approach (RBAC + Policy)
   - Separation of duties
   - Audit trails and compliance

## 🔒 Security Model

The labs implement a multi-layered security approach:

| Layer | Control | Purpose |
|-------|---------|---------|
| **RBAC** | Who can access | Controls which users can perform actions |
| **Policy** | What can be done | Enforces compliance rules on resources |
| **Tags** | Approval tracking | Documents authorization and approval |
| **Audit** | Monitoring | Logs all activities for compliance |

## 📋 Prerequisites

- **Azure Subscription** with sufficient permissions (Owner or Contributor)
- **Azure CLI** installed ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **Azure ML Extension**: `az extension add --name ml`
- **Basic Knowledge** of Azure, CLI, and bash scripting

## 💰 Cost Considerations

Running these labs will incur Azure charges:

- **Storage Account**: Minimal (few cents per day)
- **Key Vault**: Minimal (few cents per day)
- **AI Services (S0 tier)**: ~$0.50-1.00 per hour
- **AI Hub/Project**: Based on compute usage

**💡 Tip**: Complete all labs in a single session (< 1 hour) and run Lab 4 cleanup immediately to minimize costs.

## 🛠️ Troubleshooting

### Common Issues

**Issue**: `az ml` command not found  
**Solution**: Install the Azure ML extension: `az extension add --name ml`

**Issue**: Policy not enforcing  
**Solution**: Wait 5-15 minutes for policy propagation

**Issue**: Insufficient permissions  
**Solution**: Ensure you have Owner or Contributor role

See individual lab READMEs for more specific troubleshooting.

## 📖 Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/en-us/azure/ai-studio/)
- [Azure RBAC Documentation](https://docs.microsoft.com/en-us/azure/role-based-access-control/)
- [Azure Policy Documentation](https://docs.microsoft.com/en-us/azure/governance/policy/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is provided as-is for educational purposes.

## ⚠️ Disclaimer

These labs are for demonstration and learning purposes. Always follow your organization's security policies and best practices when implementing access controls in production environments.
