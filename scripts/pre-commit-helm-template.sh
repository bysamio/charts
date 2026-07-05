#!/bin/bash
# Pre-commit hook to test Helm template rendering
# This script tests that all charts can be templated without errors
# Tests multiple Kubernetes versions to catch compatibility issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

source "$SCRIPT_DIR/helm-local-deps.sh"

echo "🧪 Testing Helm template rendering..."

CHARTS=("keycloak" "postgresql" "mariadb" "memcached" "wordpress" "minio" "gotenberg" "casepack-api" "casepack-spa" "casepack-docs" "casepack")
KUBE_VERSIONS=("1.28" "1.30" "1.32")
FAILED=0

for chart in "${CHARTS[@]}"; do
    if [ ! -d "$chart" ]; then
        echo "⚠️  Chart directory '$chart' not found, skipping..."
        continue
    fi

    echo "📦 Testing chart: $chart"

    # Build dependencies from Chart.lock without regenerating lock files.
    if grep -q "^dependencies:" "$chart/Chart.yaml"; then
        echo "  ↳ Building dependencies..."
        prepare_local_oci_dependencies "$chart"
        if ! helm dependency build "$chart" > /dev/null 2>&1; then
            if [ "$LOCAL_DEPS_PREPARED" -eq 1 ] && dependency_status_ok "$chart"; then
                echo "  ↳ Using local chart cache for same-repo dependencies"
            else
                echo "  ❌ Failed to build dependencies"
                helm dependency build "$chart"
                FAILED=1
                echo ""
                continue
            fi
        fi
    fi

    # Test with default values
    for kube_version in "${KUBE_VERSIONS[@]}"; do
        echo "  ↳ Testing with kube-version: $kube_version"

        # Chart-specific test values
        TEST_ARGS=""
        if [ "$chart" == "wordpress" ]; then
            TEST_ARGS="--set wordpressPassword=test-password --set mariadb.auth.rootPassword=test-root-password --set mariadb.auth.password=test-db-password"
        fi

        if helm template "test-$chart" "$chart" \
            --kube-version "$kube_version" \
            $TEST_ARGS \
            --debug > /dev/null 2>&1; then
            echo "    ✅ $chart ($kube_version): Passed"
        else
            echo "    ❌ $chart ($kube_version): Failed"
            echo "    Running with debug to show errors:"
            helm template "test-$chart" "$chart" \
                --kube-version "$kube_version" \
                $TEST_ARGS \
                --debug 2>&1 | head -50
            FAILED=1
        fi
    done
    echo ""
done

if [ $FAILED -eq 1 ]; then
    echo "❌ Some charts failed template rendering. Please fix the errors above."
    exit 1
fi

echo "✅ All charts rendered successfully!"
exit 0
