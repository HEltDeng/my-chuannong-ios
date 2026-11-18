#!/usr/bin/env python3
"""Preserve App Group entitlements before Xcode cloud-signs an unsigned archive.

An archive built with CODE_SIGNING_ALLOWED=NO has no signature from which the
exporter can read entitlements. Attach an ad-hoc signature to both executables;
Xcode replaces it with an Apple Distribution signature during App Store export.
This intermediate archive is not an installable or uploadable distribution.
"""

import argparse
import plistlib
import subprocess
import tempfile
from pathlib import Path


GROUP_KEY = "com.apple.security.application-groups"
APP_ID = "com.mychuannong.app"
GROUP_ID = "group.com.mychuannong.app"


def run(*args):
    return subprocess.run(args, capture_output=True, check=True)


def prepare(archive):
    metadata = plistlib.loads((archive / "Info.plist").read_bytes())
    relative = Path(metadata["ApplicationProperties"]["ApplicationPath"])
    products = (archive / "Products").resolve()
    app = (products / relative).resolve()
    if not app.is_relative_to(products) or app.suffix != ".app":
        raise ValueError("Archive has an invalid application path")

    widget = app / "PlugIns/SchoolWidgets.appex"
    bundles = [widget, app]
    versions = []
    for bundle, identifier in [(widget, APP_ID + ".widgets"), (app, APP_ID)]:
        info = plistlib.loads((bundle / "Info.plist").read_bytes())
        if info.get("CFBundleIdentifier") != identifier:
            raise ValueError("Expected the production app and school widget")
        if info.get("AppGroupIdentifier") != GROUP_ID:
            raise ValueError("The production App Group is missing from Info.plist")
        versions.append((info["CFBundleShortVersionString"], info["CFBundleVersion"]))
    if versions[0] != versions[1]:
        raise ValueError("The app and widget versions must match")

    if "AMapAPIKey" in info or any(key.startswith(("NSLocation", "NSPhotoLibrary")) for key in info):
        raise ValueError("Removed map/location or full-photo-library permissions must not remain in this release")

    for bundle in bundles:
        signature = subprocess.run(["codesign", "-dvv", str(bundle)], capture_output=True)
        if signature.returncode == 0 and b"Signature=adhoc" not in signature.stderr:
            raise ValueError("Expected an unsigned or ad-hoc archive; keep distribution archives unchanged")
        if signature.returncode != 0 and b"not signed at all" not in signature.stderr:
            raise ValueError("Unable to inspect the archive's existing signature")

    # Sign the embedded extension first so the app seals its final signature.
    # Keep the temporary entitlements next to the local archive, outside source.
    with tempfile.TemporaryDirectory(prefix="archive-entitlements-", dir=archive.parent) as temporary:
        for bundle in bundles:
            entitlements = Path(temporary) / (bundle.name + ".entitlements")
            entitlements.write_bytes(plistlib.dumps({GROUP_KEY: [GROUP_ID]}))
            run("codesign", "--force", "--sign", "-", "--entitlements", str(entitlements),
                "--generate-entitlement-der", str(bundle))

        for bundle in bundles:
            run("codesign", "--verify", "--strict", str(bundle))
            result = run("codesign", "-d", "--entitlements", ":-", str(bundle))
            if plistlib.loads(result.stdout).get(GROUP_KEY) != [GROUP_ID]:
                raise ValueError("App Group entitlement was not preserved")

    print("Prepared app and widget entitlements for App Store distribution export.")
    print("Version: " + " (".join(versions[0]) + ")")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    options = parser.parse_args()
    prepare(options.archive.expanduser().resolve())
