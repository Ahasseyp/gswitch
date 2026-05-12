#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Ahasseyp/gswitch"
BIN_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.local/share/gswitch"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [[ ! -f "${SCRIPT_DIR}/bin/gs" ]]; then
  echo "Downloading gswitch..."
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL "${REPO_URL}/archive/refs/heads/main.tar.gz" | tar -xz -C "$tmp" --strip-components=1
  SCRIPT_DIR="$tmp"
fi

echo ""
bold "Installing gswitch"
echo ""

# Install binaries
mkdir -p "$BIN_DIR"
for cmd in gs gsadd gsrm; do
  cp "${SCRIPT_DIR}/bin/${cmd}" "${BIN_DIR}/${cmd}"
  chmod +x "${BIN_DIR}/${cmd}"
  echo "  installed ${BIN_DIR}/${cmd}"
done

# Ensure data dir exists
mkdir -p "$DATA_DIR"

# Install zsh completion
COMPLETION_INSTALLED=false

if [[ -n "${ZSH:-}" && -d "${ZSH_CUSTOM:-${ZSH}/custom}/completions" ]]; then
  COMP_DIR="${ZSH_CUSTOM:-${ZSH}/custom}/completions"
  mkdir -p "$COMP_DIR"
  cp "${SCRIPT_DIR}/completions/_gs" "${COMP_DIR}/_gs"
  echo "  installed ${COMP_DIR}/_gs"
  COMPLETION_INSTALLED=true
else
  # Try first writable fpath dir
  while IFS= read -r dir; do
    [[ -z "$dir" ]] && continue
    if [[ -w "$dir" ]]; then
      cp "${SCRIPT_DIR}/completions/_gs" "${dir}/_gs"
      echo "  installed ${dir}/_gs"
      COMPLETION_INSTALLED=true
      break
    fi
  done < <(zsh -c 'printf "%s\n" "${fpath[@]}"' 2>/dev/null || true)
fi

if [[ "$COMPLETION_INSTALLED" == "false" ]]; then
  echo ""
  red "Could not auto-install zsh completion."
  echo "Manually copy completions/_gs to a directory on your fpath, then run:"
  echo "  rm -f ~/.zcompdump && exec zsh"
fi

# Warn if BIN_DIR is not on PATH
if ! echo ":${PATH}:" | grep -q ":${BIN_DIR}:"; then
  echo ""
  red "Warning: ${BIN_DIR} is not on your PATH."
  echo "Add this to your ~/.zshrc:"
  echo "  export PATH=\"\${HOME}/.local/bin:\${PATH}\""
fi

echo ""
green "Done! Run 'exec zsh' to reload your shell."
echo ""
bold "Commands:"
echo "  gs          — fuzzy-switch to a tracked branch"
echo "  gsadd       — start tracking the current branch"
echo "  gsrm        — stop tracking the current branch"
