#!/usr/bin/env python3
"""Regenerate Formula/atbbs.rb from the latest PyPI release."""

import json
import subprocess
import time
import urllib.request
import sys


def get_pypi_info(package: str, version: str | None = None):
    url = f"https://pypi.org/pypi/{package}/json" if not version else f"https://pypi.org/pypi/{package}/{version}/json"
    with urllib.request.urlopen(url) as r:
        return json.loads(r.read())


def get_sdist(pypi_data: dict) -> tuple[str, str]:
    for u in pypi_data["urls"]:
        if u["packagetype"] == "sdist":
            return u["url"], u["digests"]["sha256"]
    raise RuntimeError(f"No sdist found for {pypi_data['info']['name']}")


def has_c_extension(pypi_data: dict) -> bool:
    """A package has C extensions if it publishes platform-specific wheels."""
    for u in pypi_data["urls"]:
        if u["packagetype"] == "bdist_wheel" and not u["filename"].endswith("-none-any.whl"):
            return True
    return False


def resolve_deps(package: str, version: str, python_version: str) -> list[tuple[str, str]]:
    for attempt in range(5):
        result = subprocess.run(
            [
                "uv", "pip", "compile",
                "--python-version", python_version,
                "--no-header",
                "--refresh-package", package,
                "-",
            ],
            input=f"{package}=={version}",
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            break
        if attempt < 4:
            wait = 30 * (attempt + 1)
            print(f"  Resolve failed, retrying in {wait}s (PyPI propagation delay)...")
            time.sleep(wait)
        else:
            print(result.stderr, file=sys.stderr)
            sys.exit(1)

    deps = []
    for line in result.stdout.strip().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        name, _, ver = line.partition("==")
        name = name.strip()
        ver = ver.strip()
        if name.lower() == package.lower():
            continue
        # Provided by Homebrew's cryptography formula
        if name.lower() in ("cryptography", "cffi", "pycparser"):
            continue
        deps.append((name, ver))
    return deps


def generate_formula(version: str, url: str, sha256: str,
                     resources: list[dict], wheel_deps: list[dict]) -> str:
    resource_blocks = []
    for r in resources:
        resource_blocks.append(
            f'  resource "{r["name"]}" do\n'
            f'    url "{r["url"]}"\n'
            f'    sha256 "{r["sha256"]}"\n'
            f'  end'
        )

    resources_str = "\n\n".join(resource_blocks)

    if wheel_deps:
        wheel_args = ", ".join(f'"{d["name"]}=={d["version"]}"' for d in wheel_deps)
        install_block = (
            f'  def install\n'
            f'    python = "python3.14"\n'
            f'    venv = virtualenv_create(libexec, python)\n'
            f'\n'
            f'    # Install C-extension packages from pre-built wheels.\n'
            f'    system python, "-m", "pip", "--python=#{{libexec}}/bin/python",\n'
            f'           "install", "--no-deps", "--ignore-installed",\n'
            f'           {wheel_args}\n'
            f'\n'
            f'    venv.pip_install resources\n'
            f'    venv.pip_install_and_link buildpath\n'
            f'  end'
        )
    else:
        install_block = (
            f'  def install\n'
            f'    virtualenv_install_with_resources\n'
            f'  end'
        )

    return (
        f'class Atbbs < Formula\n'
        f'  include Language::Python::Virtualenv\n'
        f'\n'
        f'  desc "AT Protocol bulletin board system"\n'
        f'  homepage "https://github.com/alyraffauf/atbbs"\n'
        f'  url "{url}"\n'
        f'  sha256 "{sha256}"\n'
        f'  license "AGPL-3.0-or-later"\n'
        f'\n'
        f'  depends_on "cryptography"\n'
        f'  depends_on "python@3.14"\n'
        f'\n'
        f'{resources_str}\n'
        f'\n'
        f'{install_block}\n'
        f'\n'
        f'  test do\n'
        f'    assert_match version.to_s, shell_output("#{{bin}}/atbbs --version")\n'
        f'  end\n'
        f'end\n'
    )


def main():
    version = sys.argv[1] if len(sys.argv) > 1 else None

    print("Fetching atbbs info from PyPI...")
    pypi = get_pypi_info("atbbs", version)
    version = pypi["info"]["version"]
    url, sha256 = get_sdist(pypi)
    print(f"  Version: {version}")
    print(f"  URL: {url}")

    print("Resolving dependencies...")
    deps = resolve_deps("atbbs", version, "3.14")
    print(f"  Found {len(deps)} dependencies")

    print("Fetching dependency info...")
    resources = []
    wheel_deps = []
    for name, ver in deps:
        dep_pypi = get_pypi_info(name, ver)
        if has_c_extension(dep_pypi):
            wheel_deps.append({"name": name, "version": ver})
            print(f"  {name}=={ver} (wheel)")
        else:
            dep_url, dep_sha256 = get_sdist(dep_pypi)
            resources.append({"name": name, "url": dep_url, "sha256": dep_sha256})
            print(f"  {name}=={ver}")

    print("Generating formula...")
    formula = generate_formula(version, url, sha256, resources, wheel_deps)

    with open("Formula/atbbs.rb", "w") as f:
        f.write(formula)

    print(f"Formula/atbbs.rb updated to {version}")


if __name__ == "__main__":
    main()
