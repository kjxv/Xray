#!/bin/bash

# 视频教程的固定版本。发布新教程时使用新标签，不要移动旧标签。
is_sh_repo=kjxv/Xray
is_sh_ref=tutorial-v1.35
is_core_default_ver=v26.3.27
is_caddy_default_ver=v2.11.7
is_jq_ver=jq-1.7.1

# GitHub 源码归档带有顶层目录，先完整校验再复制到安装目录。
install_script_archive() {
    local archive=$1 destination=$2 staging source_file
    local roots=()
    staging=$(mktemp -d) || return 1
    if ! unzip -qo "$archive" -d "$staging"; then
        rm -rf "$staging"
        return 1
    fi
    roots=("$staging"/*)
    if [[ ${#roots[@]} != 1 || ! -d ${roots[0]} ]]; then
        rm -rf "$staging"
        return 1
    fi
    for source_file in install.sh xray.sh LICENSE src/init.sh src/core.sh src/download.sh src/release.sh; do
        if [[ ! -f ${roots[0]}/$source_file ]]; then
            rm -rf "$staging"
            return 1
        fi
    done
    if ! grep -Fxq "is_sh_repo=$is_sh_repo" "${roots[0]}/src/release.sh" ||
        ! grep -Fxq "is_sh_ref=$is_sh_ref" "${roots[0]}/src/release.sh"; then
        rm -rf "$staging"
        return 1
    fi
    for source_file in "${roots[0]}/install.sh" "${roots[0]}/xray.sh" "${roots[0]}"/src/*.sh; do
        if ! bash -n "$source_file"; then
            rm -rf "$staging"
            return 1
        fi
    done
    if ! mkdir -p "$destination" || ! cp -R "${roots[0]}/." "$destination/"; then
        rm -rf "$staging"
        return 1
    fi
    printf '%s\n' "$is_sh_ref" >"$destination/script-ref"
    local result=$?
    rm -rf "$staging"
    return "$result"
}
