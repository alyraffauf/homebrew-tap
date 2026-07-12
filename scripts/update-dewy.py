#!/usr/bin/env python3
"""Update Formula/dewy.rb with the latest release from GitHub."""

import hashlib
import json
import re
import sys
import urllib.error
import urllib.request

GITHUB_API_TIMEOUT_SECONDS = 30
DOWNLOAD_TIMEOUT_SECONDS = 60
FORMULA_PATH = "Formula/dewy.rb"


def get_latest_version() -> str:
    url = "https://api.github.com/repos/alyraffauf/dewy/tags"
    try:
        with urllib.request.urlopen(url, timeout=GITHUB_API_TIMEOUT_SECONDS) as response:
            tags = json.loads(response.read())
    except urllib.error.HTTPError as error:
        sys.exit(f"Failed to fetch tags from GitHub: HTTP {error.code} {error.reason}")

    if not tags:
        sys.exit("No tags found for alyraffauf/dewy")

    return tags[0]["name"].removeprefix("v")


def download_and_hash(version: str) -> tuple[str, str]:
    url = f"https://github.com/alyraffauf/dewy/archive/refs/tags/v{version}.tar.gz"
    try:
        with urllib.request.urlopen(url, timeout=DOWNLOAD_TIMEOUT_SECONDS) as response:
            data = response.read()
    except urllib.error.HTTPError as error:
        sys.exit(f"Failed to download {url}: HTTP {error.code} {error.reason}")

    return url, hashlib.sha256(data).hexdigest()


def update_formula(url: str, sha256: str) -> None:
    with open(FORMULA_PATH) as file:
        content = file.read()

    content = re.sub(r'^  url "[^"]+"', f'  url "{url}"', content, count=1, flags=re.MULTILINE)
    content = re.sub(r'^  sha256 "[^"]+"', f'  sha256 "{sha256}"', content, count=1, flags=re.MULTILINE)

    with open(FORMULA_PATH, "w") as file:
        file.write(content)


def main():
    version = sys.argv[1] if len(sys.argv) > 1 else None

    if version is None:
        print("Fetching latest dewy version from GitHub...")
        version = get_latest_version()

    print(f"  Version: {version}")

    print("Downloading tarball and computing sha256...")
    url, sha256 = download_and_hash(version)
    print(f"  URL: {url}")
    print(f"  SHA256: {sha256}")

    print("Updating formula...")
    update_formula(url, sha256)

    print(f"Formula/dewy.rb updated to {version}")


if __name__ == "__main__":
    main()
