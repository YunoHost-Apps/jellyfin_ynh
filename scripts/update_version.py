#!/usr/bin/env python3

from pathlib import Path
import tomlkit
import requests

REPO_ROOT = Path(__file__).parent.parent

JELLYFIN_REPO = "https://repo.jellyfin.org/releases/server/debian"

ARCHS = [
    "armhf",
    "arm64",
    "amd64",
]

DEBS = [
    "buster",
    "bullseye",
    "bookworm",
]


def version_from__common_sh(name: str) -> str:
    content = (REPO_ROOT/"scripts"/"_common.sh").open(encoding="utf-8").readlines()
    result = next(filter(lambda line: line.startswith(f"{name}="), content))
    return result.split('"')[1]


def server_url(arch: str, version: str) -> str:
    version_simple = version.split("-")[0]
    return f"{JELLYFIN_REPO}/versions/stable/server/{version_simple}/jellyfin-server_{version}_{arch}.deb"


def web_url(arch: str, version: str) -> str:
    version_simple = version.split("-")[0]
    return f"{JELLYFIN_REPO}/versions/stable/web/{version_simple}/jellyfin-web_{version}_all.deb"


def ffmpeg_url(arch: str, deb: str, version: str) -> str:
    major = version.split(".")[0]
    return f"{JELLYFIN_REPO}/versions/jellyfin-ffmpeg/{version}/jellyfin-ffmpeg{major}_{version}-{deb}_{arch}.deb"


def sha256sum_of(url: str) -> str:
    result = requests.get(f"{url}.sha256sum", timeout=10)

    content = result.content.decode("utf-8")
    return content.split(" ")[0]


def main() -> None:
    manifest_file = REPO_ROOT/"manifest.toml"
    manifest = tomlkit.parse(manifest_file.open(encoding="utf-8").read())

    jellyfin_version = version_from__common_sh("pkg_version")
    ffmpeg_version = version_from__common_sh("ffmpeg_pkg_version")
    ldap_version = version_from__common_sh("ldap_pkg_version")

    for arch in ARCHS:
        url = server_url(arch, jellyfin_version)
        manifest["resources"]["sources"]["server"][arch]["url"] = url
        manifest["resources"]["sources"]["server"][arch]["sha256"] = sha256sum_of(url)

    url = web_url(arch, jellyfin_version)
    manifest["resources"]["sources"]["web"]["url"] = url
    manifest["resources"]["sources"]["web"]["sha256"] = sha256sum_of(url)

    for arch in ARCHS:
        for deb in DEBS:
            url = ffmpeg_url(arch, deb, ffmpeg_version)
            manifest["resources"]["sources"][f"ffmpeg_{deb}"][arch]["url"] = url
            manifest["resources"]["sources"][f"ffmpeg_{deb}"][arch]["sha256"] = sha256sum_of(url)

    manifest_file.open("w", encoding="utf-8").write(tomlkit.dumps(manifest))



if __name__ == "__main__":
    main()
