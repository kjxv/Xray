# 默认只下载 src/release.sh 声明的教程版本。
get_pinned_version() {
    case $1 in
    core | dat) download_ver=$is_core_default_ver ;;
    sh) download_ver=$is_sh_ref ;;
    caddy) download_ver=$is_caddy_default_ver ;;
    *) err "无法识别下载类型: $1" ;;
    esac
}

download() {
    download_ver=$2
    [[ ! $download_ver ]] && get_pinned_version "$1"
    [[ $1 == sh && $download_ver != "$is_sh_ref" ]] && {
        err "教程脚本固定为 $is_sh_ref, 不能通过更新命令切换脚本版本."
    }
    tmpdir=$(mktemp -d) || err "无法创建临时目录."
    case $1 in
    core | dat)
        name=$is_core_name
        tmpfile=$tmpdir/$is_core.zip
        link="https://github.com/${is_core_repo}/releases/download/${download_ver}/${is_core_name}-linux-${is_core_arch}.zip"
        download_file
        if [[ $1 == dat ]]; then
            unzip -qo "$tmpfile" geoip.dat geosite.dat -d "$tmpdir/data" || download_error
            cp -f "$tmpdir/data/geoip.dat" "$tmpdir/data/geosite.dat" "$is_core_dir/bin/" || download_error
        else
            unzip -qo "$tmpfile" -d "$is_core_dir/bin" || download_error
            chmod +x "$is_core_bin" || download_error
        fi
        ;;
    sh)
        name="$is_core_name 脚本"
        tmpfile=$tmpdir/sh.zip
        link="https://codeload.github.com/${is_sh_repo}/zip/refs/tags/${download_ver}"
        download_file
        install_script_archive "$tmpfile" "$is_sh_dir" || download_error
        chmod +x "$is_sh_bin" || download_error
        ;;
    caddy)
        name="Caddy"
        tmpfile=$tmpdir/caddy.tar.gz
        link="https://github.com/${is_caddy_repo}/releases/download/${download_ver}/caddy_${download_ver#v}_linux_${caddy_arch}.tar.gz"
        download_file
        [[ ! $(type -P tar) ]] && {
            rm -rf "$tmpdir"
            err "请安装 tar"
        }
        tar zxf "$tmpfile" -C "$tmpdir" || download_error
        cp -f "$tmpdir/caddy" "$is_caddy_bin" || download_error
        chmod +x "$is_caddy_bin" || download_error
        ;;
    *)
        rm -rf "$tmpdir"
        err "无法识别下载类型: $1"
        ;;
    esac
    rm -rf "$tmpdir"
    unset download_ver
}

download_error() {
    rm -rf "$tmpdir"
    err "下载或解压 ${name} 失败. 教程模式不会回退到最新版."
}

download_file() {
    _wget -t 5 -c "$link" -O "$tmpfile" || download_error
}
