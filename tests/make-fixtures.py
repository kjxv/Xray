"""Build disposable offline download fixtures for the Bash regression checks."""

import io
from pathlib import Path
import sys
import tarfile
import zipfile

repo, destination = map(Path, sys.argv[1:])
destination.mkdir(parents=True, exist_ok=True)
files = [repo / name for name in ("install.sh", "xray.sh", "README.md", "LICENSE")]
files.extend(sorted((repo / "src").glob("*.sh")))

for variant in ("script", "missing", "wrong-repo", "syntax-error"):
    with zipfile.ZipFile(destination / f"{variant}.zip", "w") as archive:
        for path in files:
            relative = path.relative_to(repo).as_posix()
            if variant == "missing" and relative == "src/init.sh":
                continue
            content = path.read_bytes()
            if variant == "wrong-repo" and relative == "src/release.sh":
                content = content.replace(b"is_sh_repo=kjxv/Xray", b"is_sh_repo=other/Xray")
            if variant == "syntax-error" and relative == "xray.sh":
                content += b"\nif\n"
            archive.writestr(f"Xray-tutorial-v1.35/{relative}", content)

with zipfile.ZipFile(destination / "core.zip", "w") as archive:
    archive.writestr("xray", "#!/bin/bash\necho offline-core\n")
    archive.writestr("geoip.dat", "pinned-geoip\n")
    archive.writestr("geosite.dat", "pinned-geosite\n")

with tarfile.open(destination / "caddy.tar.gz", "w:gz") as archive:
    content = b"#!/bin/bash\necho offline-caddy\n"
    member = tarfile.TarInfo("caddy")
    member.size = len(content)
    member.mode = 0o755
    archive.addfile(member, io.BytesIO(content))
