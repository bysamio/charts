#!/bin/bash
# Pre-commit hook to check Helm chart dependencies
# Ensures all dependencies are properly defined and can be resolved

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

source "$SCRIPT_DIR/helm-local-deps.sh"

echo "📋 Checking Helm chart dependencies..."

# Add external Helm repos required by chart dependencies
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm > /dev/null 2>&1 || true
helm repo update > /dev/null 2>&1

CHARTS=("keycloak" "postgresql" "mariadb" "memcached" "wordpress" "minio" "gotenberg" "casepack-api" "casepack-spa" "casepack-docs" "casepack")
FAILED=0

for chart in "${CHARTS[@]}"; do
    if [ ! -f "$chart/Chart.yaml" ]; then
        continue
    fi

    echo "📦 Checking dependencies for: $chart"

    # Check if chart has dependencies
    if grep -q "^dependencies:" "$chart/Chart.yaml"; then
        echo "  ↳ Chart has dependencies, verifying..."

        prepare_local_oci_dependencies "$chart"

        # Try to build dependencies
        if helm dependency build "$chart" > /dev/null 2>&1; then
            echo "  ✅ Dependencies resolved successfully"
        elif [ "$LOCAL_DEPS_PREPARED" -eq 1 ] && dependency_status_ok "$chart"; then
            echo "  ✅ Dependencies resolved using local chart cache"
        else
            echo "  ❌ Failed to resolve dependencies"
            helm dependency build "$chart"
            FAILED=1
        fi
    else
        echo "  ↳ No dependencies (OK)"
    fi
    echo ""
done

if [ $FAILED -eq 1 ]; then
    echo "❌ Some charts have dependency issues. Please fix them."
    exit 1
fi

echo "✅ All dependencies are valid!"
exit 0
