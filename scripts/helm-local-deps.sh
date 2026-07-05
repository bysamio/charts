#!/bin/bash
# Helpers for resolving same-repository OCI chart dependencies during local checks.

LOCAL_OCI_REPO="${LOCAL_OCI_REPO:-oci://ghcr.io/bysamio/charts}"
LOCAL_DEPS_PREPARED=0

chart_has_dependencies() {
    local chart="$1"
    grep -q "^dependencies:" "$chart/Chart.yaml" 2>/dev/null
}

chart_metadata_version() {
    local chart="$1"
    local version
    version=$(awk '$1 == "version:" { print $2; exit }' "$chart/Chart.yaml")
    version=${version//\"/}
    version=${version//\'/}
    echo "$version"
}

prepare_local_oci_dependencies() {
    local chart="$1"
    LOCAL_DEPS_PREPARED=0

    if ! chart_has_dependencies "$chart"; then
        return 0
    fi

    while read -r name version repository status; do
        if [ -z "$name" ] || [ "$name" = "NAME" ]; then
            continue
        fi

        if [ "$repository" != "$LOCAL_OCI_REPO" ] || [ ! -f "$name/Chart.yaml" ]; then
            continue
        fi

        # Parent charts need their own dependency build. Only cache leaf charts.
        if chart_has_dependencies "$name"; then
            continue
        fi

        if [ "$(chart_metadata_version "$name")" != "$version" ]; then
            continue
        fi

        mkdir -p "$chart/charts"

        local package
        for package in "$chart/charts/${name}-"*.tgz; do
            if [ ! -e "$package" ]; then
                continue
            fi
            if [ "${package##*/}" != "${name}-${version}.tgz" ]; then
                rm -f "$package"
            fi
        done

        helm package "$name" --destination "$chart/charts" > /dev/null
        LOCAL_DEPS_PREPARED=1
    done < <(helm dependency list "$chart" 2>/dev/null | tail -n +2)
}

dependency_status_ok() {
    local chart="$1"
    local dependencies

    if ! dependencies=$(helm dependency list "$chart" 2>/dev/null); then
        return 1
    fi

    while read -r name version repository status; do
        if [ -z "$name" ] || [ "$name" = "NAME" ]; then
            continue
        fi
        if [ "$status" != "ok" ]; then
            return 1
        fi
    done <<< "$dependencies"

    return 0
}
