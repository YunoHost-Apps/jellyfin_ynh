#!/usr/bin/env python3

from typing import Any, Tuple, Dict, Optional, List
from pathlib import Path
import hashlib
import tomlkit
import requests
import hashlib
from copy import deepcopy

REPO_ROOT = Path(__file__).parent.parent

JELLYFIN_REPO = "https://repo.jellyfin.org"

ARCHS = [
    "armhf",
    "arm64",
    "amd64",
]

DEBS = {
    "bullseye": "11",
    "bookworm": "12",
}

class JellyfinDistro:
    def __init__(self, debian_number: str, debian_name: str, arch: List[str]):
        self.debian_number = debian_number
        self.debian_name = debian_name
        self.arch = arch

    # Version in form of 10.9.0-2
    def server_url(self, version: str, arch: str) -> str:
        return f"{JELLYFIN_REPO}/files/server/debian/stable/v{version}/{arch}/jellyfin-server_{version}+deb{self.debian_number}_{arch}.deb"

    def web_url(self, version: str) -> str:
        return f"{JELLYFIN_REPO}/files/server/debian/stable/v{version}/amd64/jellyfin-web_{version}+deb{self.debian_number}_all.deb"

    def ffmpeg_url(self, version: str, arch: str) -> str:
        major = version.split(".")[0]
        return f"{JELLYFIN_REPO}/files/ffmpeg/debian/{major}.x/{version}/{arch}/jellyfin-ffmpeg7_{version}-{self.debian_name}_{arch}.deb"

    def ldap_url(self, version: str) -> str:
        return f"{JELLYFIN_REPO}/files/plugin/ldap-authentication/ldap-authentication_{version}.zip"

    def update_package(self, manifest: Dict, package: str, version: str):
        url = None
        urls = {}
        archive_needed = False
        if package == "server":
            for arch in self.arch: urls[arch] = self.server_url(version, arch)
            key = f"server_{self.debian_name}"
            extra = { "format": "whatever", "extract": False, "rename": "jellyfin-server.deb", "prefetch": False }
            archive_needed = True
            archive_key = f"server_archive_{self.debian_name}"
        elif package == "web":
            url = self.web_url(version)
            key = f"web_{self.debian_name}"
            extra = { "format": "whatever", "extract": False, "rename": "jellyfin-web.deb", "prefetch": False }
            archive_needed = True
            archive_key = f"web_archive_{self.debian_name}"
        elif package == "ffmpeg":
            for arch in self.arch: urls[arch] = self.ffmpeg_url(version, arch)
            key = f"ffmpeg_{self.debian_name}"
            extra = { "format": "whatever", "extract": False, "rename": "jellyfin-ffmpeg6.deb" }
        elif package == "ldap":
            url = self.ldap_url(version)
            key = "plugin_ldap"
            extra = {"in_subdir": False}
        else: raise Exception(f"Wrong jellyfin package: {package}")

        if key not in manifest["resources"]["sources"]:
            manifest["resources"]["sources"][key] = {}

        # Single URL, not per arch
        if url:
            print(f"Checking for updates for Jellyfin's {package} (distro={self.debian_name}) to version {version}")
            self.update_package_helper(manifest["resources"]["sources"][key], package, version, url)
            if archive_needed:
                manifest["resources"]["sources"][archive_key] = deepcopy(manifest["resources"]["sources"][key])
                # Create the archive entry with the url updated
                manifest["resources"]["sources"][archive_key]["url"] = url.replace(f"{JELLYFIN_REPO}/files", f"{JELLYFIN_REPO}/archive")
        else:
            # Different URL per architecture
            for arch, url in urls.items():
                if arch not in manifest["resources"]["sources"][key]:
                    manifest["resources"]["sources"][key][arch] = {}
                    
                print(f"Checking for updates for Jellyfin's {package} (arch={arch},distro={self.debian_name}) to version {version}")
                self.update_package_helper(manifest["resources"]["sources"][key][arch], package, version, url)
                # Create the archive entry with the url updated
            if archive_needed:
                manifest["resources"]["sources"][archive_key] = deepcopy(manifest["resources"]["sources"][key])
                for arch, url in urls.items():
                    manifest["resources"]["sources"][archive_key][arch]["url"] = url.replace(f"{JELLYFIN_REPO}/files", f"{JELLYFIN_REPO}/archive")

        # Add extra settings
        for k, v in extra.items():
            manifest["resources"]["sources"][key][k] = v
            if archive_needed:
                manifest["resources"]["sources"][archive_key][k] = v


    def update_package_helper(self, entry: Dict, package: str, version: str, url: str):
        # Assume version changed only if URL changed
        if "url" in entry and entry["url"] == url:
            print(f"    Already at version {version} in manifest.toml.")
            return

        sha = sha256sum_of(url)
        entry["url"] = url
        entry["sha256"] = sha
        print(f"    Updated to version {version}.")

def version_from__common_sh(name: str) -> str:
    content = (REPO_ROOT/"scripts"/"_common.sh").open(encoding="utf-8").readlines()
    result = next(filter(lambda line: line.startswith(f"{name}="), content))
    return result.split('"')[1]

def sha256sum_of(url: str) -> str:
    # No more sha256sum files provided on release repo?
    result = requests.get(url, timeout=10)
    if result.status_code != 200 and not (result.status_code > 300 and result.status_code < 400):
        raise Exception(f"Wrong status code on URL {url}: {result.status_code}")

    hasher = hashlib.sha256()
    hasher.update(result.content)
    return hasher.hexdigest()

def main() -> None:
    manifest_file = REPO_ROOT/"manifest.toml"
    manifest: dict[str, Any] = tomlkit.parse(manifest_file.open(encoding="utf-8").read())

    jellyfin_version = version_from__common_sh("pkg_version")
    ffmpeg_version = version_from__common_sh("ffmpeg_pkg_version")
    ldap_version = version_from__common_sh("ldap_pkg_version")

    for debian_name, debian_number in DEBS.items():
        jellyfin = JellyfinDistro(debian_number, debian_name, ARCHS)
        jellyfin.update_package(manifest, "server", jellyfin_version)
        jellyfin.update_package(manifest, "web", jellyfin_version)
        jellyfin.update_package(manifest, "ffmpeg", ffmpeg_version)
        jellyfin.update_package(manifest, "ldap", ldap_version)

    manifest_file.open("w", encoding="utf-8").write(tomlkit.dumps(manifest))

if __name__ == "__main__":
    main()
