# Pre-commit Scripts

These scripts are used by pre-commit hooks to validate Helm charts before commits.

## Scripts

- **pre-commit-helm-lint.sh**: Lints all Helm charts using `helm lint`
- **pre-commit-helm-template.sh**: Tests template rendering for all charts with multiple Kubernetes versions
- **pre-commit-helm-deps.sh**: Verifies chart dependencies can be resolved

## Manual Usage

You can run these scripts manually:

```bash
# Lint all charts
./scripts/pre-commit-helm-lint.sh

# Test template rendering
./scripts/pre-commit-helm-template.sh

# Check dependencies
./scripts/pre-commit-helm-deps.sh
```

## Installation

1. Install pre-commit:
   ```bash
   pip install pre-commit
   # or
   brew install pre-commit
   ```

2. Install the hooks:
   ```bash
   pre-commit install
   ```

3. Test the hooks:
   ```bash
   pre-commit run --all-files
   ```

## Customization

Edit `.pre-commit-config.yaml` to:
- Add more hooks
- Skip certain hooks
- Modify hook configurations
- Add chart-specific validations
