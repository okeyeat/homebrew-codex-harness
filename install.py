#!/usr/bin/env python3
"""Download and install the published Codex Harness release (Python 3.9+)."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request

VERSION = '0.3.0'
ASSETS = {'darwin-arm64': {'name': 'codex-harness-0.3.0-darwin-arm64.tar.gz', 'sha256': 'f08051ff8b21fda45bc811049cfdc10ab5ebfbc1a3715d380a6fb7735fa29d15'}, 'darwin-amd64': {'name': 'codex-harness-0.3.0-darwin-amd64.tar.gz', 'sha256': 'c7e3b0f3d67af29b339542c0745e52baba815f4a714f7f13fb23a864761e88de'}, 'linux-arm64': {'name': 'codex-harness-0.3.0-linux-arm64.tar.gz', 'sha256': '342905a16f3b7cf6f7dc91e8660be453a365b800b449637dffd74582fb192888'}, 'linux-amd64': {'name': 'codex-harness-0.3.0-linux-amd64.tar.gz', 'sha256': 'd2c8c86ac2a53d9317eea8b40b364567c037393de19bcfc20035880ed8cf44cd'}}
BASE_URL = 'https://github.com/okeyeat/homebrew-codex-harness/releases/download'


def unpack(archive: Path, destination: Path) -> None:
    with tarfile.open(archive, 'r:gz') as tar:
        members = tar.getmembers()
        if sum(member.size for member in members) > 128 * 1024 * 1024:
            raise ValueError('Unpacked archive exceeds the size limit.')
        for member in members:
            path = PurePosixPath(member.name)
            if path.is_absolute() or '..' in path.parts or not path.parts or path.parts[0] != 'codex-harness':
                raise ValueError('Unsafe archive path.')
            if not (member.isfile() or member.isdir()):
                raise ValueError('Archive links and special files are not allowed.')
        for member in members:
            target = destination.joinpath(*PurePosixPath(member.name).parts)
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with tar.extractfile(member) as source, target.open('wb') as output:
                    shutil.copyfileobj(source, output)
                target.chmod(0o700 if member.mode & 0o111 else 0o600)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--codex-home', type=Path)
    parser.add_argument('--runtime-home', type=Path)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    system = {'Darwin': 'darwin', 'Linux': 'linux'}.get(platform.system())
    arch = {'arm64': 'arm64', 'aarch64': 'arm64', 'x86_64': 'amd64', 'AMD64': 'amd64'}.get(platform.machine())
    key = f'{system}-{arch}'
    if key not in ASSETS:
        print('Unsupported platform. Use macOS or Linux (including WSL) on arm64 or x86_64.', file=sys.stderr)
        return 1
    try:
        # Keep staging beside the requested installation, not in a system temp folder.
        runtime = args.runtime_home or Path(os.environ.get('HARNESS_RUNTIME_HOME', str(Path.home() / '.local/share/codex-harness/session-runtime')))
        parent = runtime.expanduser().resolve().parent
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='.download-', dir=parent) as name:
            staging = Path(name)
            archive = staging / 'release.tar.gz'
            asset = ASSETS[key]
            url = f'{BASE_URL}/v{VERSION}/{asset["name"]}'
            request = urllib.request.Request(url, headers={'User-Agent': 'codex-harness-installer'})
            digest = hashlib.sha256()
            with urllib.request.urlopen(request, timeout=60) as response, archive.open('wb') as output:
                count = 0
                while block := response.read(1024 * 1024):
                    count += len(block)
                    if count > 64 * 1024 * 1024:
                        raise ValueError('Download exceeds the size limit.')
                    digest.update(block); output.write(block)
            if digest.hexdigest() != asset['sha256']:
                raise ValueError('Release checksum mismatch; nothing installed.')
            unpack(archive, staging)
            command = [sys.executable, str(staging / 'codex-harness/setup.py')]
            for option, value in [('--codex-home', args.codex_home), ('--runtime-home', args.runtime_home)]:
                if value is not None:
                    command.extend([option, str(value)])
            if args.dry_run:
                command.append('--dry-run')
            return subprocess.run(command, check=False).returncode
    except (OSError, ValueError, tarfile.TarError) as error:
        print(f'Installation failed: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
