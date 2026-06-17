#!/bin/bash
# Pre-commit hook to check Helm chart dependencies
# Ensures all dependencies are properly defined and can be resolved

set -e

echo "📋 Checking Helm chart dependencies..."

CHARTS=("keycloak" "postgresql" "mariadb" "memcached" "wordpress" "minio" "casepack-api" "casepack-spa" "casepack")
FAILED=0

for chart in "${CHARTS[@]}"; do
    if [ ! -f "$chart/Chart.yaml" ]; then
        continue
    fi

    echo "📦 Checking dependencies for: $chart"

    # Check if chart has dependencies
    if grep -q "^dependencies:" "$chart/Chart.yaml"; then
        echo "  ↳ Chart has dependencies, verifying..."

        cd "$chart"

        # Try to build dependencies
        if helm dependency build > /dev/null 2>&1; then
            echo "  ✅ Dependencies resolved successfully"
        else
            echo "  ❌ Failed to resolve dependencies"
            helm dependency build
            FAILED=1
        fi

        cd ..
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
