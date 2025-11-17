# Lab 1: Set up AI Foundry Resource via Azure CLI

## Overview

This lab demonstrates how to set up an Azure AI Foundry resource using Azure CLI. Azure AI Foundry provides a unified platform for building, deploying, and managing AI applications.

## Prerequisites

- Azure CLI installed ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- Azure subscription with appropriate permissions
- Logged in to Azure CLI (`az login`)
- Azure Machine Learning extension installed: `az extension add --name ml`

## Architecture

The lab sets up the following resources:

```
Resource Group
├── Storage Account (for AI Hub storage)
├── Key Vault (for secrets management)
├── AI Services (Cognitive Services)
├── AI Hub (ML Workspace hub)
└── AI Project (ML Workspace project)
```

## Instructions

### 1. Verify Prerequisites

Ensure you're logged in to Azure:

```bash
az login
az account show
```

Install Azure ML extension if not already installed:

```bash
az extension add --name ml --upgrade
```

### 2. Run the Setup Script

Make the script executable and run it:

```bash
chmod +x setup-ai-foundry.sh
./setup-ai-foundry.sh
```

### 3. Custom Configuration (Optional)

You can customize the deployment by setting environment variables:

```bash
export RESOURCE_GROUP_NAME="my-custom-rg"
export LOCATION="westus2"
export AI_FOUNDRY_NAME="my-ai-foundry"

./setup-ai-foundry.sh
```

### 4. Verify the Deployment

After the script completes, verify the resources were created:

```bash
# List all resources in the resource group
az resource list --resource-group rg-ai-foundry-demo --output table

# Check AI Hub
az ml workspace show --name <AI_HUB_NAME> --resource-group rg-ai-foundry-demo

# Check AI Project
az ml workspace show --name <AI_PROJECT_NAME> --resource-group rg-ai-foundry-demo
```

## What Gets Created

1. **Resource Group**: Container for all AI Foundry resources
2. **Storage Account**: Stores artifacts, models, and datasets
3. **Key Vault**: Securely stores secrets and credentials
4. **AI Services**: Provides cognitive services capabilities
5. **AI Hub**: Central hub for AI projects and shared resources
6. **AI Project**: Individual project workspace for AI development

## Configuration File

The script generates an `ai-foundry-config.env` file containing all resource information. Source this file in subsequent labs:

```bash
source ai-foundry-config.env
```

## Troubleshooting

### Issue: "az ml command not found"
**Solution**: Install the Azure ML extension:
```bash
az extension add --name ml
```

### Issue: "Insufficient permissions"
**Solution**: Ensure you have Contributor role or higher on the subscription

### Issue: "Resource name already exists"
**Solution**: The script uses random suffixes to avoid conflicts. If needed, set custom names using environment variables.

## Cost Considerations

- Storage Account: Pay-as-you-go based on storage used
- Key Vault: Minimal cost for basic operations
- AI Services: S0 tier has hourly charges
- AI Hub/Project: Costs based on compute usage

**Recommendation**: Complete all labs in a single session and run Lab 4 cleanup to avoid unnecessary charges.

## Next Steps

After completing Lab 1, proceed to:
- **Lab 2**: Set up role-based access control for DeepSeek models
- **Lab 3**: Implement Azure Policy for deployment governance
- **Lab 4**: Clean up resources

## Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/en-us/azure/ai-studio/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure Machine Learning CLI](https://docs.microsoft.com/en-us/azure/machine-learning/reference-azure-machine-learning-cli)
