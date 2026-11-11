#!/bin/sh
# Installs Herdr (app and core) on Linux from this folder alone, for a network
# with no internet at all. Copy the whole folder over, then in it:
#
#   sh install-offline.sh
#
# To update, put a newer copy in its place and run this again.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
base="file://$(printf '%s' "$here" | sed 's/ /%20/g')"

# The manifests name downloads on the mirror they were made for: point them here.
for f in app/latest.json core/latest.json; do
  sed -i -E "s#\"url\": *\"[^\"]*/((app|core)/[^/\"]+/[^/\"]+)\"#\"url\": \"$base/\\1\"#" "$here/$f"
done

export HERDR_RELEASES_URL="$base"
# The core first, every time: its installer installs or updates it, and the
# app's then finds it there.
sh "$here/core/install.sh"
sh "$here/app/install.sh"
