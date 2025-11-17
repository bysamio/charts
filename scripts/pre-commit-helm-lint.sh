#!/bin/bash
# Pre-commit hook to lint Helm charts
# This script lints all Helm charts in the repository

set -e

echo "🔍 Linting Helm charts..."

CHARTS=("mariadb" "memcached" "wordpress")
FAILED=0

for chart in "${CHARTS[@]}"; do
    if [ ! -d "$chart" ]; then
        echo "⚠️  Chart directory '$chart' not found, skipping..."
        continue
    fi

    echo "📦 Linting chart: $chart"

    if helm lint "$chart" 2>&1; then
        echo "✅ $chart: Passed"
    else
        echo "❌ $chart: Failed"
        FAILED=1
    fi
    echo ""
done

if [ $FAILED -eq 1 ]; then
    echo "❌ Some charts failed linting. Please fix the errors above."
    exit 1
fi

echo "✅ All charts passed linting!"
exit 0
