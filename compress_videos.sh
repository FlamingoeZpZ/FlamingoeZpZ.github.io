#!/bin/bash
# ─────────────────────────────────────────────────────────────
# compress_videos.sh — fast single-pass VP9 encoder
# Optimised for speed over perfection (hover thumbnails don't
# need broadcast quality). Skips files already under 1MB.
# Originals backed up as *.webm.bak before any changes.
# ─────────────────────────────────────────────────────────────

TARGET_WIDTH=960
CRF=33
SKIP_UNDER_KB=1000

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VIDEO_DIR="$SCRIPT_DIR/Assets/Videos"

if [ ! -d "$VIDEO_DIR" ]; then
  echo "ERROR: Could not find Assets/Videos/ — run this from your repo root."
  exit 1
fi

echo ""
echo "🎬 Video compressor (fast mode) — scanning $VIDEO_DIR"
echo "   Width: ${TARGET_WIDTH}px | CRF: $CRF | Skipping files under ${SKIP_UNDER_KB}KB"
echo ""

while IFS= read -r -d '' INPUT; do

  case "$INPUT" in *.bak) continue ;; esac

  if [ -f "${INPUT}.bak" ]; then
    echo "  ⏭  SKIP  $(basename "$INPUT")  (already processed)"
    continue
  fi

  SIZE_BEFORE=$(stat -c%s "$INPUT" 2>/dev/null || stat -f%z "$INPUT")
  SIZE_BEFORE_KB=$(( SIZE_BEFORE / 1024 ))

  if [ "$SIZE_BEFORE_KB" -lt "$SKIP_UNDER_KB" ]; then
    echo "  ⏭  SKIP  $(basename "$INPUT")  (${SIZE_BEFORE_KB}KB — already small)"
    continue
  fi

  TMPFILE="${INPUT%.webm}_tmp_$$.webm"

  echo "  ⚙  Compressing  $(basename "$INPUT")  (${SIZE_BEFORE_KB}KB) ..."

  # Single-pass, fast VP9 — no two-pass overhead
  if ! ffmpeg -y -i "$INPUT" \
    -c:v libvpx-vp9 \
    -crf "$CRF" -b:v 0 \
    -vf "scale=${TARGET_WIDTH}:-2" \
    -an \
    -cpu-used 5 -deadline realtime \
    -row-mt 1 \
    "$TMPFILE" 2>/dev/null; then
    echo "     ❌ Failed — skipping"
    rm -f "$TMPFILE"
    continue
  fi

  SIZE_AFTER=$(stat -c%s "$TMPFILE" 2>/dev/null || stat -f%z "$TMPFILE")
  SIZE_AFTER_KB=$(( SIZE_AFTER / 1024 ))

  if [ "$SIZE_AFTER" -ge "$SIZE_BEFORE" ]; then
    echo "     ⚠  Not smaller (${SIZE_AFTER_KB}KB vs ${SIZE_BEFORE_KB}KB) — keeping original"
    rm -f "$TMPFILE"
    continue
  fi

  SAVED=$(( (SIZE_BEFORE - SIZE_AFTER) * 100 / SIZE_BEFORE ))
  cp "$INPUT" "${INPUT}.bak"
  mv "$TMPFILE" "$INPUT"

  echo "     ✅ ${SIZE_BEFORE_KB}KB  →  ${SIZE_AFTER_KB}KB  (saved ${SAVED}%)"

done < <(find "$VIDEO_DIR" -name "*.webm" -print0 | sort -z)

echo ""
echo "─────────────────────────────────────────────────────────"
echo "✨ Done! Check videos in browser, then delete backups:"
echo "   find Assets/Videos -name '*.bak' -delete"
echo "─────────────────────────────────────────────────────────"