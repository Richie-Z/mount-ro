compare_hashes() {
  local file1="$1"
  local file2="$2"
  local label="$3"

  echo "[VS] Comparing hashes: $file1 vs $file2"

  if cmp -s <(cut -d ' ' -f1 "$file1") <(cut -d ' ' -f1 "$file2"); then
    echo "✅ $label match."
  else
    echo "❌ $label do NOT match!"
  fi
}
