#!/bin/bash
# Pre-commit hook to test changed Helm charts on minikube
# Only tests charts that have been modified in the current commit

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Get changed charts from staged files
get_changed_charts() {
    local charts=()
    local changed_files
    changed_files=$(git diff --cached --name-only 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || echo "")

    for file in $changed_files; do
        # Extract chart name from path (first directory)
        local chart_dir
        chart_dir=$(echo "$file" | cut -d'/' -f1)

        # Check if it's a valid chart directory
        if [ -f "$chart_dir/Chart.yaml" ]; then
            # Add to array if not already present
            if [[ ! " ${charts[*]} " =~ " ${chart_dir} " ]]; then
                charts+=("$chart_dir")
            fi
        fi
    done

    echo "${charts[@]}"
}

# Check prerequisites
check_prerequisites() {
    if ! command -v helm &> /dev/null; then
        log_error "helm is not installed"
        exit 1
    fi

    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi

    if ! command -v minikube &> /dev/null; then
        log_error "minikube is not installed"
        exit 1
    fi

    # Check if minikube is running
    if ! minikube status &> /dev/null; then
        log_warn "minikube is not running, skipping deployment test"
        return 1
    fi

    return 0
}

# Test a single chart
test_chart() {
    local chart="$1"
    local namespace="test-${chart}"
    local release="test-${chart}"

    log_info "Testing chart: $chart"

    # Update dependencies
    if [ -f "$chart/Chart.lock" ] || grep -q "dependencies:" "$chart/Chart.yaml" 2>/dev/null; then
        helm dependency update "$chart" > /dev/null 2>&1 || true
    fi

    # Lint
    if ! helm lint "$chart" > /dev/null 2>&1; then
        log_error "$chart: Lint failed"
        return 1
    fi
    log_info "$chart: Lint passed"

    # Template render test
    if ! helm template "$release" "$chart" > /dev/null 2>&1; then
        log_error "$chart: Template render failed"
        return 1
    fi
    log_info "$chart: Template render passed"

    # Dry-run install (if minikube available)
    if minikube status &> /dev/null; then
        kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f - > /dev/null 2>&1

        # Build install command with chart-specific values
        local install_args="--namespace $namespace --dry-run=server --timeout 30s"

        case "$chart" in
            keycloak)
                install_args="$install_args --set auth.adminPassword=testpass123 --set postgresql.auth.postgresPassword=testpass123 --set postgresql.auth.password=testpass123 --set usePasswordFiles=false"
                ;;
            postgresql)
                install_args="$install_args --set auth.postgresPassword=testpass123 --set auth.password=testpass123"
                ;;
            mariadb)
                install_args="$install_args --set auth.rootPassword=testpass123"
                ;;
            wordpress)
                install_args="$install_args --set wordpressPassword=testpass123 --set mariadb.auth.rootPassword=testpass123"
                ;;
        esac

        if ! helm install "$release" "$chart" $install_args > /dev/null 2>&1; then
            log_error "$chart: Dry-run install failed"
            kubectl delete namespace "$namespace" --ignore-not-found > /dev/null 2>&1
            return 1
        fi
        log_info "$chart: Dry-run install passed"

        kubectl delete namespace "$namespace" --ignore-not-found > /dev/null 2>&1
    fi

    return 0
}

# Main
main() {
    echo "🧪 Testing changed Helm charts..."
    echo ""

    local changed_charts
    changed_charts=$(get_changed_charts)

    if [ -z "$changed_charts" ]; then
        log_info "No chart changes detected"
        exit 0
    fi

    echo "Changed charts: $changed_charts"
    echo ""

    check_prerequisites || true

    local failed=0
    for chart in $changed_charts; do
        if ! test_chart "$chart"; then
            failed=1
        fi
        echo ""
    done

    if [ $failed -eq 1 ]; then
        log_error "Some charts failed testing"
        exit 1
    fi

    log_info "All changed charts passed testing!"
    exit 0
}

main "$@"
