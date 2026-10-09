#!/bin/bash
# 离线验证：所有下载和服务操作均使用临时文件或替身。
set -e
repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_dir"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
checks=0
assert_equal() {
    if [[ $1 != "$2" ]]; then
        printf 'FAIL: %s\nExpected: %s\nActual: %s\n' "$3" "$2" "$1" >&2
        exit 1
    fi
    checks=$((checks + 1))
}
err() { printf '%s\n' "$*" >&2; exit 1; }
msg() { :; }
_green() { printf '%s' "$*"; }
manage() { :; }
load() { source "$repo_dir/src/$1"; }

for script in install.sh xray.sh src/*.sh tests/*.sh; do
    bash -n "$script"
done
if grep -Eq 'releases/latest|get_latest_version|is_sh_repo=\$author' install.sh src/init.sh src/download.sh src/core.sh; then
    err 'Found an unpinned download/update entry point.'
fi
source src/release.sh
assert_equal "$(sed -n 's/^is_sh_repo=//p' install.sh)" "$is_sh_repo" 'bootstrap repository'
assert_equal "$(sed -n 's/^is_sh_ref=//p' install.sh)" "$is_sh_ref" 'bootstrap tag'
assert_equal "$(sed -n 's/^is_sh_ver=//p' xray.sh)" 'v1.35' 'original script version'

fixture_dir=$test_dir/fixtures
fixture_arg=$fixture_dir
repo_arg=$repo_dir
if command -v cygpath >/dev/null; then
    fixture_arg=$(cygpath -w "$fixture_dir")
    repo_arg=$(cygpath -w "$repo_dir")
fi
"${PYTHON:-python3}" tests/make-fixtures.py "$repo_arg" "$fixture_arg"

destination="$test_dir/installed script"
install_script_archive "$fixture_dir/script.zip" "$destination"
assert_equal "$(cat "$destination/script-ref")" "$is_sh_ref" 'archive installation records tag'
[[ -f $destination/src/init.sh && -f $destination/xray.sh && ! -d $destination/Xray-tutorial-v1.35 ]]
for bad_archive in missing wrong-repo syntax-error; do
    printf 'unchanged\n' >"$destination/marker"
    if install_script_archive "$fixture_dir/$bad_archive.zip" "$destination" 2>/dev/null; then
        err "Accepted invalid archive: $bad_archive"
    fi
    assert_equal "$(cat "$destination/marker")" 'unchanged' "reject $bad_archive before copying"
done

requests=$test_dir/requests
: >"$requests"
_wget() {
    local request_url output
    while [[ $# -gt 0 ]]; do
        case $1 in
        https://*) request_url=$1; shift ;;
        -O) output=$2; shift 2 ;;
        *) shift ;;
        esac
    done
    printf '%s\n' "$request_url" >>"$requests"
    [[ $MOCK_DOWNLOAD_FAIL == 1 ]] && return 1
    case $request_url in
    https://codeload.github.com/*) cp "$fixture_dir/script.zip" "$output" ;;
    */src/release.sh) cp "$repo_dir/src/release.sh" "$output" ;;
    */Xray-linux-*.zip) cp "$fixture_dir/core.zip" "$output" ;;
    */caddy_*.tar.gz) cp "$fixture_dir/caddy.tar.gz" "$output" ;;
    */jq-linux-*) printf 'offline-jq\n' >"$output" ;;
    *) err "Unexpected URL: $request_url" ;;
    esac
}
is_core=xray
is_core_name=Xray
is_core_repo=xtls/xray-core
is_core_arch=64
is_jq_arch=amd64
is_core_ver=$is_core_default_ver
is_caddy_repo=caddyserver/caddy
caddy_arch=amd64
is_core_dir=$test_dir/core
is_core_bin=$is_core_dir/bin/xray
is_sh_dir=$destination
is_sh_bin=$is_sh_dir/xray.sh
is_caddy_bin=$test_dir/caddy
mkdir -p "$is_core_dir/bin"

# 独立安装器与运行时的下载函数都必须使用固定地址。
source <(sed -n '/^download() {$/,/^}$/p' install.sh)
for item in core sh jq; do
    printf -v "tmp$item" '%s' "$test_dir/install-$item"
    printf -v "is_${item}_ok" '%s' "$test_dir/install-$item-ok"
    download "$item"
done
assert_equal "$(sed -n '1p' "$requests")" "https://github.com/$is_core_repo/releases/download/$is_core_default_ver/Xray-linux-64.zip" 'installer core URL and asset case'
assert_equal "$(sed -n '2p' "$requests")" "https://codeload.github.com/$is_sh_repo/zip/refs/tags/$is_sh_ref" 'installer repository/tag URL'
assert_equal "$(sed -n '3p' "$requests")" "https://github.com/jqlang/jq/releases/download/$is_jq_ver/jq-linux-amd64" 'installer jq URL'

# 验证安装器到下载阶段的完整流程；截断后续部署，避免触及系统目录。
run_install_flow() (
    set +e
    source <(sed -n '/^pass_args() {$/,/^}$/p' install.sh)
    source <(sed -n '/^main() {$/,/^    # test \$is_core_file/p' install.sh | sed '$d'; printf '}\n')
    tmpdir=$(mktemp -d "$test_dir/install-flow.XXXXXX")
    for marker in is_pkg_ok is_core_ok is_sh_ok is_jq_ok; do
        printf -v "$marker" '%s' "$tmpdir/$marker"
    done
    is_sh_bin=$tmpdir/not-installed
    is_core_dir=$tmpdir/core
    is_sh_dir=$tmpdir/sh
    is_conf_dir=$tmpdir/conf
    is_pkg='wget unzip'
    is_core_file= is_core_ver= local_install= jq_not_found= ip=
    clear() { :; }
    timedatectl() { :; }
    install_pkg() { : >"$is_pkg_ok"; }
    get_ip() { ip=192.0.2.1; }
    download() {
        case $1 in
        core) : >"$is_core_ok" ;;
        sh) : >"$is_sh_ok" ;;
        jq) : >"$is_jq_ok" ;;
        esac
    }
    check_status() {
        [[ -f $is_pkg_ok && -f $is_core_ok && -f $is_sh_ok && -f $is_jq_ok ]] || exit 1
        printf '%s\n' "${is_core_ver:-custom-file}" "$is_sh_ref" >"$test_dir/install-flow-result"
    }
    exit_and_del_tmpdir() { exit 1; }
    main "$@"
)
run_install_flow >/dev/null
assert_equal "$(sed -n '1p' "$test_dir/install-flow-result")" "$is_core_default_ver" 'online installer loads default core pin'
assert_equal "$(tail -n1 "$requests")" "https://raw.githubusercontent.com/$is_sh_repo/$is_sh_ref/src/release.sh" 'online installer loads pins from same tag'
before=$(wc -l <"$requests")
run_install_flow --local-install >/dev/null
assert_equal "$(wc -l <"$requests")" "$before" 'local installer loads pins without remote script request'
run_install_flow --core-version 26.3.27 >/dev/null
assert_equal "$(sed -n '1p' "$test_dir/install-flow-result")" "$is_core_default_ver" 'installer honors explicit core version'
run_install_flow --core-file "$fixture_dir/core.zip" >/dev/null
assert_equal "$(sed -n '1p' "$test_dir/install-flow-result")" 'custom-file' 'local core file does not conflict with default pin'

source src/download.sh
for architecture in 64 arm64-v8a; do
    is_core_arch=$architecture
    download core
    assert_equal "$(tail -n1 "$requests")" "https://github.com/$is_core_repo/releases/download/$is_core_default_ver/Xray-linux-$architecture.zip" "runtime core $architecture"
done
for architecture in amd64 arm64; do
    caddy_arch=$architecture
    download caddy
    assert_equal "$(tail -n1 "$requests")" "https://github.com/$is_caddy_repo/releases/download/$is_caddy_default_ver/caddy_${is_caddy_default_ver#v}_linux_$architecture.tar.gz" "runtime Caddy $architecture"
done
printf 'preserved-core\n' >"$is_core_bin"
download dat
assert_equal "$(cat "$is_core_bin")" 'preserved-core' 'data restore leaves executable unchanged'
assert_equal "$(cat "$is_core_dir/bin/geoip.dat")" 'pinned-geoip' 'pinned geoip data'
assert_equal "$(cat "$is_core_dir/bin/geosite.dat")" 'pinned-geosite' 'pinned geosite data'
download sh
assert_equal "$(cat "$is_sh_dir/script-ref")" "$is_sh_ref" 'runtime script tag'
if (download sh main) 2>/dev/null; then err 'Allowed script switch to main'; fi
before=$(wc -l <"$requests")
if (MOCK_DOWNLOAD_FAIL=1; download core) 2>/dev/null; then err 'Ignored failed download'; fi
assert_equal "$(wc -l <"$requests")" "$((before + 1))" 'failure makes no fallback request'

# 更新路径既不能使用上一次遗留的版本变量，也不能离开教程脚本标签。
source src/core.sh
msg() { :; }
_green() { printf '%s' "$*"; }
manage() { :; }
is_sh_ver=v1.35
is_sh_installed_ref=$is_sh_ref
before=$(wc -l <"$requests")
update sh
assert_equal "$(wc -l <"$requests")" "$before" 'pinned script update performs no download'
if (update sh v9.99) 2>/dev/null; then err 'Allowed arbitrary script version'; fi
is_core_ver='Xray 0.0.0'
is_new_ver=v99.99
update core
wait
assert_equal "$(tail -n1 "$requests")" "https://github.com/$is_core_repo/releases/download/$is_core_default_ver/Xray-linux-$is_core_arch.zip" 'default update restores pin and clears stale version'
update core 26.3.27
wait
assert_equal "$is_new_ver" "$is_core_default_ver" 'explicit core version normalization'

# 重装必须使用卸载前保存的本机快照，不获取远端脚本。
export REINSTALL_LOG=$test_dir/reinstall.log
cat >"$is_sh_dir/install.sh" <<'EOF'
#!/bin/bash
[[ -f src/release.sh && -f script-ref ]] || exit 1
printf '%s\n' "$*" "$(cat script-ref)" >"$REINSTALL_LOG"
EOF
uninstall() { rm -rf "$is_sh_dir"; return 0; }
before=$(wc -l <"$requests")
get reinstall
assert_equal "$(sed -n '1p' "$REINSTALL_LOG")" '--local-install' 'reinstall uses local installer'
assert_equal "$(sed -n '2p' "$REINSTALL_LOG")" "$is_sh_ref" 'reinstall retains installed snapshot'
assert_equal "$(wc -l <"$requests")" "$before" 'reinstall does not fetch another script'

printf 'PASS: syntax, pinned download paths, archive validation, updates and reinstall (%s assertions).\n' "$checks"
