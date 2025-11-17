# Contributing to Azure AI Foundry Access Management Labs

Thank you for your interest in contributing! This document provides guidelines for contributing to this repository.

## 🤝 How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. **Check existing issues** first to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Azure CLI version, OS, and relevant environment details
   - Screenshots if applicable

### Suggesting Enhancements

For new features or improvements:

1. **Open an issue** describing:
   - The use case or problem
   - Proposed solution
   - Alternative solutions considered
   - Impact on existing labs

### Submitting Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes** following our guidelines
4. **Test thoroughly** in a real Azure environment
5. **Update documentation** to reflect your changes
6. **Submit a pull request** with:
   - Description of changes
   - Related issue number (if applicable)
   - Testing performed
   - Screenshots (if UI changes)

## 📝 Development Guidelines

### Script Standards

All bash scripts should:

- Start with `#!/bin/bash`
- Use `set -e` for error handling
- Include descriptive comments
- Use meaningful variable names
- Provide clear output messages with emojis (✅ ❌ ⚠️)
- Handle errors gracefully
- Include usage examples in comments

Example:
```bash
#!/bin/bash
# Purpose: Setup AI Foundry resources
# Usage: ./setup-ai-foundry.sh

set -e

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-default-rg}"

# Validate prerequisites
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found"
    exit 1
fi

echo "✅ Starting setup..."
```

### JSON Standards

Policy and role definitions should:

- Be properly formatted (use `jq` or JSON formatter)
- Include meaningful display names and descriptions
- Use parameterization where appropriate
- Follow Azure Policy/RBAC schema exactly

### Documentation Standards

README files should include:

1. **Overview**: Clear description of purpose
2. **Prerequisites**: Required tools and permissions
3. **Instructions**: Step-by-step guide
4. **Examples**: Real command examples
5. **Troubleshooting**: Common issues and solutions
6. **Resources**: Links to official documentation

Use this structure:
```markdown
# Lab Title

## Overview
Brief description

## Prerequisites
- Item 1
- Item 2

## Instructions
### Step 1: ...
### Step 2: ...

## Troubleshooting
### Issue: ...
**Solution**: ...

## Additional Resources
- [Link](url)
```

## 🧪 Testing Requirements

### Before Submitting

1. **Syntax Check**:
   ```bash
   bash -n script.sh
   python3 -m json.tool file.json
   ```

2. **Real Azure Testing**:
   - Run scripts in a test subscription
   - Verify all resources are created correctly
   - Test error handling
   - Verify cleanup works properly

3. **Documentation Review**:
   - Check for typos and grammar
   - Verify all links work
   - Ensure examples are accurate
   - Test commands in documentation

### Test Checklist

- [ ] Script runs without errors
- [ ] Error messages are helpful
- [ ] Resources are created successfully
- [ ] Configuration files are generated correctly
- [ ] Cleanup removes all resources
- [ ] Documentation matches actual behavior
- [ ] Code follows style guidelines

## 🎨 Code Style

### Bash

- Use 4 spaces for indentation
- Use lowercase for variables (except CONSTANTS)
- Quote all variables: `"$VAR"`
- Use `$(command)` instead of backticks
- Functions should have descriptive names

### JSON

- Use 2 spaces for indentation
- Keep consistent formatting
- Use meaningful property names
- Include comments in descriptions

### Markdown

- Use ATX-style headers (`#`)
- Add blank lines around headers
- Use code fences with language tags
- Keep lines under 120 characters when possible

## 🔒 Security Considerations

### Never Commit

- API keys or secrets
- Personal subscription IDs
- Real email addresses
- Production resource names

### Always Include

- Warnings about costs
- Security disclaimers
- Permission requirements
- Data sensitivity notes

### Best Practices

- Use Azure Key Vault references
- Implement least privilege
- Document security implications
- Validate user input

## 📋 PR Review Process

### What Reviewers Look For

1. **Functionality**: Does it work as intended?
2. **Code Quality**: Is it clean and maintainable?
3. **Documentation**: Is it well-documented?
4. **Testing**: Has it been tested?
5. **Security**: Are there any security concerns?
6. **Breaking Changes**: Does it affect existing users?

### Review Timeline

- Initial review: Within 3-5 business days
- Follow-up: Based on feedback complexity
- Merge: After approval from maintainers

## 🐛 Bug Fix Guidelines

### Priority Levels

1. **Critical**: Security issues, data loss, complete failure
2. **High**: Major functionality broken
3. **Medium**: Partial functionality affected
4. **Low**: Minor issues, cosmetic problems

### Bug Fix Process

1. Create issue describing the bug
2. Fork and create fix in a branch
3. Add tests if applicable
4. Update documentation
5. Submit PR referencing the issue

## 📦 Release Process

### Versioning

This project follows semantic versioning:
- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number bumped
- [ ] Git tag created
- [ ] Release notes written

## 🏷️ Commit Message Guidelines

Use conventional commit format:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

**Examples**:
```
feat(lab2): add support for custom role names

fix(lab3): correct policy definition syntax

docs(readme): add troubleshooting section
```

## 📞 Communication

### Discussions

Use GitHub Discussions for:
- Questions about usage
- Feature discussions
- Best practices sharing
- Community support

### Issues

Use GitHub Issues for:
- Bug reports
- Feature requests
- Documentation improvements

### Pull Requests

Use Pull Requests for:
- Code contributions
- Documentation updates
- Bug fixes

## 🎓 Learning Resources

### Azure Documentation
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/)
- [Azure RBAC](https://docs.microsoft.com/en-us/azure/role-based-access-control/)

### Development Tools
- [ShellCheck](https://www.shellcheck.net/) - Bash linter
- [jq](https://stedolan.github.io/jq/) - JSON processor
- [VS Code](https://code.visualstudio.com/) - Recommended editor

## 📜 Code of Conduct

### Our Pledge

We pledge to make participation in this project a harassment-free experience for everyone.

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Enforcement

Violations of the code of conduct should be reported to the project maintainers.

## 🙏 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in documentation (if significant contribution)

## ❓ Questions?

If you have questions about contributing:
- Open a GitHub Discussion
- Review existing issues and PRs
- Contact project maintainers

---

Thank you for contributing to making AI development more secure and governed! 🚀
