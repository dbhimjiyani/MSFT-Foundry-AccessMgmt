# Azure AI Foundry Access Management - Architecture Diagram

## Overall Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Azure Subscription                            │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           Resource Group: rg-ai-foundry-demo                 │   │
│  │                                                               │   │
│  │  ┌──────────────────┐    ┌──────────────────┐               │   │
│  │  │  Storage Account │    │    Key Vault     │               │   │
│  │  │  (Artifacts)     │    │    (Secrets)     │               │   │
│  │  └──────────────────┘    └──────────────────┘               │   │
│  │                                                               │   │
│  │  ┌──────────────────┐    ┌──────────────────┐               │   │
│  │  │   AI Services    │    │     AI Hub       │               │   │
│  │  │ (Cognitive Svcs) │    │  (ML Workspace)  │               │   │
│  │  └──────────────────┘    └──────────────────┘               │   │
│  │                                    │                          │   │
│  │                          ┌─────────┴─────────┐               │   │
│  │                          │    AI Project     │               │   │
│  │                          │  (ML Workspace)   │               │   │
│  │                          └───────────────────┘               │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Custom RBAC Role                          │   │
│  │                                                               │   │
│  │    Name: "DeepSeek Model Reader"                             │   │
│  │    Permissions:                                               │   │
│  │      ✅ Read models and endpoints                            │   │
│  │      ✅ List API keys                                        │   │
│  │      ❌ Deploy models                                        │   │
│  │      ❌ Delete models                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Azure Policies                            │   │
│  │                                                               │   │
│  │  Policy 1: Approval Policy                                   │   │
│  │    Effect: Deny                                               │   │
│  │    Condition: DeepSeek deployment without AdminApproved tag  │   │
│  │                                                               │   │
│  │  Policy 2: Audit Policy                                      │   │
│  │    Effect: Audit                                              │   │
│  │    Condition: All DeepSeek model activities                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Security Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      User Access Request                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │  Azure Active Directory       │
              │  (Authentication)             │
              └──────────────┬────────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │  RBAC Check                   │
              │  (Does user have permission?) │
              └──────────────┬────────────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                 No │                 │ Yes
                    ▼                 ▼
            ┌──────────────┐  ┌──────────────────┐
            │   Access     │  │  Check Azure     │
            │   Denied     │  │  Policy          │
            └──────────────┘  └─────────┬────────┘
                                        │
                               ┌────────┴────────┐
                               │                 │
                          Deny │                 │ Allow/Audit
                               ▼                 ▼
                       ┌──────────────┐  ┌──────────────────┐
                       │  Operation   │  │   Operation      │
                       │  Blocked     │  │   Succeeds       │
                       └──────────────┘  └─────────┬────────┘
                                                    │
                                                    ▼
                                         ┌──────────────────┐
                                         │  Activity Log    │
                                         │  (Audit Trail)   │
                                         └──────────────────┘
```

## Lab Progression Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                             Lab 1                                   │
│                    Set up AI Foundry                                │
│                                                                      │
│  Input:                                                              │
│    • Azure subscription                                              │
│    • Azure CLI + ML extension                                        │
│                                                                      │
│  Actions:                                                            │
│    1. Create resource group                                          │
│    2. Create storage & key vault                                     │
│    3. Create AI services                                             │
│    4. Create AI hub & project                                        │
│                                                                      │
│  Output:                                                             │
│    • ai-foundry-config.env (resource IDs)                           │
│    • Fully functional AI Foundry environment                         │
└────────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                             Lab 2                                   │
│                    Set up RBAC                                      │
│                                                                      │
│  Input:                                                              │
│    • ai-foundry-config.env from Lab 1                               │
│                                                                      │
│  Actions:                                                            │
│    1. Create custom role definition                                  │
│    2. Define read-only permissions                                   │
│    3. Generate assignment instructions                               │
│                                                                      │
│  Output:                                                             │
│    • Custom role: "DeepSeek Model Reader"                           │
│    • rbac-config.env                                                 │
│    • Role assignment documentation                                   │
└────────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                             Lab 3                                   │
│                    Set up Azure Policy                              │
│                                                                      │
│  Input:                                                              │
│    • ai-foundry-config.env from Lab 1                               │
│                                                                      │
│  Actions:                                                            │
│    1. Create approval policy definition                              │
│    2. Create audit policy definition                                 │
│    3. Assign policies to resource group                              │
│                                                                      │
│  Output:                                                             │
│    • Policy: Approval enforcement                                    │
│    • Policy: Audit logging                                           │
│    • policy-config.env                                               │
│    • Deployment workflow documentation                               │
└────────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                             Lab 4                                   │
│                      Resource Cleanup                               │
│                                                                      │
│  Input:                                                              │
│    • ai-foundry-config.env from Lab 1                               │
│                                                                      │
│  Actions:                                                            │
│    1. Remove policy assignments                                      │
│    2. Delete policy definitions                                      │
│    3. Remove custom role                                             │
│    4. Delete resource group                                          │
│                                                                      │
│  Output:                                                             │
│    • All resources deleted                                           │
│    • Cleanup summary report                                          │
│    • Zero ongoing costs                                              │
└────────────────────────────────────────────────────────────────────┘
```

## User Role Comparison

```
┌──────────────────────────────────────────────────────────────────┐
│                    Action Comparison Matrix                       │
├──────────────────────┬──────────────┬──────────────┬─────────────┤
│      Action          │  No Role     │  DeepSeek    │   Admin     │
│                      │  (Default)   │  Reader      │  (Owner)    │
├──────────────────────┼──────────────┼──────────────┼─────────────┤
│ View workspace       │      ❌      │      ✅      │     ✅      │
│ List models          │      ❌      │      ✅      │     ✅      │
│ Read model details   │      ❌      │      ✅      │     ✅      │
│ View endpoints       │      ❌      │      ✅      │     ✅      │
│ Use API keys         │      ❌      │      ✅      │     ✅      │
│ Deploy models        │      ❌      │      ❌      │     ✅*     │
│ Delete models        │      ❌      │      ❌      │     ✅      │
│ Modify endpoints     │      ❌      │      ❌      │     ✅      │
│ Create deployments   │      ❌      │      ❌      │     ✅*     │
└──────────────────────┴──────────────┴──────────────┴─────────────┘

* For DeepSeek models, requires AdminApproved=true tag due to Policy
```

## Deployment Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                  Non-Admin User Request Flow                     │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │  User wants to deploy          │
        │  DeepSeek model                │
        └────────────┬───────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │  Attempt deployment            │
        └────────────┬───────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │  RBAC Check: Permission?       │
        └────────────┬───────────────────┘
                     │
                     ▼
              ❌ Denied (No permission)
                     │
                     ▼
        ┌────────────────────────────────┐
        │  Submit request to admin       │
        └────────────┬───────────────────┘
                     │
┌────────────────────┴────────────────────────────────────────────┐
│                     Admin Approval Flow                          │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │  Admin reviews request         │
        │  • Business justification      │
        │  • Security assessment         │
        │  • Compliance check            │
        └────────────┬───────────────────┘
                     │
            ┌────────┴────────┐
            │                 │
        Reject              Approve
            │                 │
            ▼                 ▼
    ┌──────────────┐  ┌──────────────────┐
    │  Notify      │  │  Admin creates   │
    │  user        │  │  deployment with │
    │              │  │  AdminApproved   │
    └──────────────┘  │  tag             │
                      └─────────┬────────┘
                                │
                                ▼
                   ┌────────────────────────────────┐
                   │  Policy Check: Has tag?        │
                   └────────────┬───────────────────┘
                                │
                                ▼
                         ✅ Allowed
                                │
                                ▼
                   ┌────────────────────────────────┐
                   │  Deployment succeeds           │
                   └────────────┬───────────────────┘
                                │
                                ▼
                   ┌────────────────────────────────┐
                   │  Audit log entry created       │
                   │  • Who deployed                │
                   │  • When deployed               │
                   │  • What was deployed           │
                   │  • Approval details            │
                   └────────────────────────────────┘
```

## Cost Accumulation Over Time

```
Lab Duration vs Cost
│
│  💰
│  ││                                                    ← With cleanup
│  ││                                            ┌───────
│  ││                                    ┌───────
│  ││                            ┌───────
│  ││                    ┌───────
│  ││            ┌───────
│  ││    ┌───────
│  ││────                                                
│  │                                                     
│  └──────┬──────┬──────┬──────┬──────┬──────┬─────────→ Time
│        Lab1   Lab2   Lab3   Lab4  +1hr   +2hr    +24hr
│        (15m)  (10m)  (15m)  (5m)
│
│        ~$0.25  $0.50  $0.75  $0     $1.50  $3.00   $24+
│
│  💰💰💰
│  ││                                                    ← Without cleanup
│  ││                                            ┌───────────────────
│  ││                                    ┌───────────────
│  ││                            ┌───────────────
│  ││                    ┌───────────────
│  ││            ┌───────────────
│  ││    ┌───────────────
│  ││────────────
│  │                                                     
│  └──────┬──────┬──────┬──────┬──────┬──────┬─────────→ Time
│        Lab1   Lab2   Lab3   No     +1hr   +2hr    +24hr
│        (15m)  (10m)  (15m)  Cleanup
│
│  Lesson: Always run Lab 4 cleanup immediately after completing labs!
```

## File Dependencies

```
Lab Scripts Dependency Graph

                    setup-ai-foundry.sh
                            │
                            ├─ creates ──┐
                            │            │
                            ▼            ▼
                  ai-foundry-config.env  Azure Resources
                            │                   │
                    ┌───────┴───────┐          │
                    │               │          │
                    ▼               ▼          │
            setup-rbac.sh    setup-policy.sh   │
                    │               │          │
                    ├─ creates ─┐   ├─ creates ─┐
                    │           │   │           │
                    ▼           ▼   ▼           ▼
            rbac-config.env  Custom  policy-   Azure
                             Role    config.   Policies
                                     env
                            │
                            │ all configs
                            │ used by
                            ▼
                     cleanup.sh
                            │
                            └─ deletes everything
```

## Legend

- ✅ = Allowed / Success
- ❌ = Denied / Failure
- ⚠️ = Warning / Attention needed
- 💰 = Cost indicator
- │ = Dependency / Flow
- ▼ = Direction of flow
- ┌─┐ = Container / Boundary
- * = Conditional / With restrictions
