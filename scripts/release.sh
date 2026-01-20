#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
PROJECT_ID="${2:-${CURSEFORGE_PROJECT_ID:-}}"
SLUG="${CURSEFORGE_SLUG:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version> [project_id]" >&2
  exit 1
fi

if [[ -z "${CURSEFORGE_API_TOKEN:-}" ]]; then
  echo "CURSEFORGE_API_TOKEN is required in the environment." >&2
  exit 1
fi

if [[ -z "$PROJECT_ID" ]]; then
  echo "CurseForge project ID is required (arg or CURSEFORGE_PROJECT_ID)." >&2
  exit 1
fi

if [[ -z "$SLUG" && "$PROJECT_ID" == "1432552" ]]; then
  SLUG="emote-control"
fi

command -v gh >/dev/null || { echo "gh is required in PATH." >&2; exit 1; }
command -v zip >/dev/null || { echo "zip is required in PATH." >&2; exit 1; }
command -v unzip >/dev/null || { echo "unzip is required in PATH." >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required in PATH." >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

perl -0pi -e "s/addon.VERSION = \"[^\"]+\"/addon.VERSION = \"$VERSION\"/" SpeakinLite/Core.lua
perl -0pi -e "s/^## Version: .*/## Version: $VERSION/m" SpeakinLite/SpeakinLite.toc

if [[ ! -f CHANGELOG.md ]]; then
  last_tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  {
    echo "## Version $VERSION - $(date +%Y-%m-%d)"
    if [[ -n "$last_tag" ]]; then
      git log --pretty=format:"- %s" "$last_tag"..HEAD
    else
      git log --pretty=format:"- %s"
    fi
    echo
  } > CHANGELOG.md
fi

git add .
if git diff --cached --quiet; then
  echo "No staged changes to commit." >&2
  exit 1
fi

git commit -m "Release v$VERSION"
git push
gh release create "v$VERSION" --generate-notes

zip_path="/tmp/EmoteControl-$VERSION.zip"
rm -f "$zip_path"
zip -r "$zip_path" SpeakinLite SpeakinLite_Pack_*
zip -T "$zip_path" >/dev/null
unzip -l "$zip_path" >/dev/null

game_version_ids="$(
  python3 - <<'PY'
import json,os,sys,urllib.request
token=os.environ["CURSEFORGE_API_TOKEN"]
url="https://wow.curseforge.com/api/game/versions"
req=urllib.request.Request(url, headers={"X-Api-Token": token})
with urllib.request.urlopen(req) as r:
    data=json.load(r)
def api_to_num(s):
    try:
        return int(str(s))
    except Exception:
        return 0
def find_exact(name):
    for v in data:
        if v.get("name") == name:
            return v.get("id")
    return None
def find_latest(prefix):
    candidates=[v for v in data if str(v.get("name","")).startswith(prefix)]
    candidates.sort(key=lambda v: api_to_num(v.get("apiVersion")), reverse=True)
    return candidates[0].get("id") if candidates else None
id_11 = find_exact("11.2.7") or find_latest("11.")
id_12 = find_exact("12.0.1") or find_latest("12.")
if not id_11 or not id_12:
    print("Failed to resolve game version IDs.", file=sys.stderr)
    sys.exit(1)
print(f"{id_11},{id_12}")
PY
)"

IFS=',' read -r gv_11 gv_12 <<< "$game_version_ids"

metadata_json="$(
  VERSION="$VERSION" GV11="$gv_11" GV12="$gv_12" python3 - <<'PY'
import json,os,re
version=os.environ["VERSION"]
changelog_path="CHANGELOG.md"
with open(changelog_path,"r",encoding="utf-8") as f:
    text=f.read()
section=""
pattern=re.compile(r"^##\\s+Version\\s+"+re.escape(version)+r"\\b.*$", re.M)
m=pattern.search(text)
if m:
    m2=pattern.search(text, m.end())
    section=text[m.start():m2.start() if m2 else len(text)]
else:
    first=re.search(r"^##\\s+Version\\b.*$", text, re.M)
    if first:
        m2=re.search(r"^##\\s+Version\\b.*$", text, first.end(), re.M)
        section=text[first.start():m2.start() if m2 else len(text)]
    else:
        section=f"## Version {version}\\n- Release"
meta={
    "changelog": section.strip(),
    "changelogType": "markdown",
    "displayName": f"EmoteControl {version}",
    "releaseType": os.environ.get("CURSEFORGE_RELEASE_TYPE","release").lower(),
    "gameVersions": [int(os.environ["GV11"]), int(os.environ["GV12"])],
}
print(json.dumps(meta))
PY
)"

upload_response="$(curl -sS -H "X-Api-Token: $CURSEFORGE_API_TOKEN" \
  -F "file=@$zip_path" \
  -F "metadata=$metadata_json" \
  "https://wow.curseforge.com/api/projects/$PROJECT_ID/upload-file")"

upload_id="$(python3 - <<'PY'
import json,sys
try:
    data=json.loads(sys.stdin.read())
    print(data.get("id",""))
except Exception:
    print("")
PY
<<<"$upload_response")"

if [[ -n "$upload_id" ]]; then
  echo "CurseForge upload file id: $upload_id"
fi

if [[ -n "$SLUG" ]]; then
  python3 - <<'PY'
import json,sys,urllib.request,os
slug=os.environ.get("SLUG","")
version=os.environ.get("VERSION","")
upload_id=os.environ.get("UPLOAD_ID","")
url=f"https://api.cfwidget.com/wow/addons/{slug}"
with urllib.request.urlopen(url) as r:
    data=json.load(r)
files=data.get("files",[])
latest=files[0] if files else {}
ok_version = latest.get("display","").endswith(version)
ok_id = (str(latest.get("id")) == str(upload_id)) if upload_id else True
if not (ok_version and ok_id):
    print("Warning: widget verification did not match latest file/version.", file=sys.stderr)
    print(f"Latest: id={latest.get('id')} display={latest.get('display')}", file=sys.stderr)
else:
    print(f"Verified widget latest: id={latest.get('id')} display={latest.get('display')}")
PY
else
  echo "CURSEFORGE_SLUG not set; skipping widget verification."
fi
