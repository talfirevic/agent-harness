#!/usr/bin/env bash
set -euo pipefail

DEFAULT_REPO="talfirevic/agent-harness"
BUNDLE_REPO="${HARNESS_BUNDLE_REPO:-$DEFAULT_REPO}"
TARGET_DIR="${HARNESS_TARGET_DIR:-$(pwd)}"

LOCAL_VERSION_FILE=".harness-bundle-version"
LOCAL_MANIFEST_FILE=".harness-managed-files"

info() {
  echo "[agent-harness-installer] $*"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

sha256_file() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
    return
  fi

  fail "No SHA-256 tool found (need sha256sum or shasum)"
}

sanitize_manifest() {
  local input_file="$1"
  local output_file="$2"
  local raw line segment

  : > "$output_file"
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    line="${raw%$'\r'}"
    [[ -n "$line" ]] || continue

    [[ "$line" != /* ]] || fail "Manifest entry must be relative: $line"
    IFS='/' read -r -a parts <<< "$line"
    for segment in "${parts[@]}"; do
      if [[ -z "$segment" || "$segment" == "." || "$segment" == ".." ]]; then
        fail "Unsafe manifest entry: $line"
      fi
    done

    printf '%s\n' "$line" >> "$output_file"
  done < "$input_file"

  sort -u "$output_file" -o "$output_file"
}

download_file() {
  local url="$1"
  local output="$2"
  curl -fsSL "$url" -o "$output" || fail "Failed to download: $url"
}

require_cmd awk
require_cmd comm
require_cmd cp
require_cmd curl
require_cmd mkdir
require_cmd rm
require_cmd sort
require_cmd tar
require_cmd tr

[[ -d "$TARGET_DIR" ]] || fail "Target directory does not exist: $TARGET_DIR"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

if [[ -n "${HARNESS_RELEASE_BASE_URL:-}" ]]; then
  asset_base_url="${HARNESS_RELEASE_BASE_URL%/}"
  release_tag="${HARNESS_RELEASE_TAG:-custom}"
else
  latest_release_url="https://github.com/${BUNDLE_REPO}/releases/latest"
  info "Resolving latest stable release for ${BUNDLE_REPO}"
  resolved_release_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "$latest_release_url")" \
    || fail "Failed to resolve latest release URL"
  release_tag="${resolved_release_url##*/}"
  [[ -n "$release_tag" && "$release_tag" != "latest" ]] || fail "Could not resolve latest release tag"
  asset_base_url="https://github.com/${BUNDLE_REPO}/releases/download/${release_tag}"
fi

info "Using release ${release_tag}"

download_file "$asset_base_url/VERSION" "$tmp_dir/VERSION"
remote_version="$(tr -d '[:space:]' < "$tmp_dir/VERSION")"
[[ -n "$remote_version" ]] || fail "Remote VERSION is empty"

local_version=""
if [[ -f "$TARGET_DIR/$LOCAL_VERSION_FILE" ]]; then
  local_version="$(tr -d '[:space:]' < "$TARGET_DIR/$LOCAL_VERSION_FILE")"
fi

if [[ -n "$local_version" && "$local_version" == "$remote_version" && -f "$TARGET_DIR/$LOCAL_MANIFEST_FILE" ]]; then
  info "Already up to date (version $remote_version)"
  exit 0
fi

download_file "$asset_base_url/MANIFEST.txt" "$tmp_dir/MANIFEST.txt"
download_file "$asset_base_url/sha256sums.txt" "$tmp_dir/sha256sums.txt"
download_file "$asset_base_url/harness-bundle.tar.gz" "$tmp_dir/harness-bundle.tar.gz"

expected_hash="$(awk '
  {
    file=$2
    gsub(/^\*/, "", file)
    if (file == "harness-bundle.tar.gz") {
      print $1
      exit 0
    }
  }
' "$tmp_dir/sha256sums.txt")"
[[ -n "$expected_hash" ]] || fail "sha256sums.txt does not contain harness-bundle.tar.gz"

actual_hash="$(sha256_file "$tmp_dir/harness-bundle.tar.gz")"
[[ "$actual_hash" == "$expected_hash" ]] \
  || fail "Checksum mismatch for harness-bundle.tar.gz"

new_manifest="$tmp_dir/new-manifest.txt"
sanitize_manifest "$tmp_dir/MANIFEST.txt" "$new_manifest"

old_manifest="$tmp_dir/old-manifest.txt"
if [[ -f "$TARGET_DIR/$LOCAL_MANIFEST_FILE" ]]; then
  sanitize_manifest "$TARGET_DIR/$LOCAL_MANIFEST_FILE" "$old_manifest"
else
  : > "$old_manifest"
fi

mkdir -p "$tmp_dir/extract"
tar -xzf "$tmp_dir/harness-bundle.tar.gz" -C "$tmp_dir/extract"

while IFS= read -r rel_path || [[ -n "$rel_path" ]]; do
  [[ -n "$rel_path" ]] || continue
  src="$tmp_dir/extract/$rel_path"
  dst="$TARGET_DIR/$rel_path"

  [[ -f "$src" ]] || fail "Bundle is missing manifest path: $rel_path"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
done < "$new_manifest"

comm -23 "$old_manifest" "$new_manifest" > "$tmp_dir/remove-manifest.txt"
while IFS= read -r rel_path || [[ -n "$rel_path" ]]; do
  [[ -n "$rel_path" ]] || continue
  dst="$TARGET_DIR/$rel_path"
  if [[ -f "$dst" || -L "$dst" ]]; then
    rm -f "$dst"
  fi
done < "$tmp_dir/remove-manifest.txt"

cp "$new_manifest" "$TARGET_DIR/$LOCAL_MANIFEST_FILE"
printf '%s\n' "$remote_version" > "$TARGET_DIR/$LOCAL_VERSION_FILE"

if [[ ! -d "$TARGET_DIR/.git" ]]; then
  if command -v git >/dev/null 2>&1; then
    (cd "$TARGET_DIR" && git init -q)
    info "Initialized git repository"
  else
    info "git not found; skipping repository initialization"
  fi
fi

cat <<EOF
[agent-harness-installer] install complete
version: $remote_version
repo: $BUNDLE_REPO

next:
  ./scripts/harness/readiness-check.sh
  ./scripts/harness/check-all.sh
  Follow paybook quickstart in paybook.md
EOF
