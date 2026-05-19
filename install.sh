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
for cmd in gs gsadd gsrm gsupdate gsclean; do
  cp "${SCRIPT_DIR}/bin/${cmd}" "${BIN_DIR}/${cmd}"
  chmod +x "${BIN_DIR}/${cmd}"
  echo "  installed ${BIN_DIR}/${cmd}"
done

# Ensure data dir exists
mkdir -p "$DATA_DIR"

# Record installed version
if [[ -f "${SCRIPT_DIR}/VERSION" ]]; then
  cp "${SCRIPT_DIR}/VERSION" "${DATA_DIR}/version"
fi

ZSHRC="${ZDOTDIR:-${HOME}}/.zshrc"

# Install zsh completion (oh-my-zsh only)
if [[ -n "${ZSH:-}" ]]; then
  COMP_DIR="${ZSH_CUSTOM:-${ZSH}/custom}/completions"
  mkdir -p "$COMP_DIR"
  cp "${SCRIPT_DIR}/completions/_gs" "${COMP_DIR}/_gs"
  echo "  installed ${COMP_DIR}/_gs"
else
  echo ""
  red "oh-my-zsh not detected — tab completion not installed."
  echo "Install oh-my-zsh at https://ohmyz.sh and re-run to enable it."
fi

# Enable oh-my-zsh git plugin (provides gwip/gunwip)
if [[ -n "${ZSH:-}" ]]; then
  if awk '/^plugins=\(/{b=1} b && /\bgit\b/{f=1} b && /^\)/{exit} END{exit !f}' "$ZSHRC" 2>/dev/null; then
    echo "  oh-my-zsh git plugin already enabled"
  else
    awk '/^plugins=\(/{print; print "  git"; next} 1' "$ZSHRC" > "${ZSHRC}.tmp" && mv "${ZSHRC}.tmp" "$ZSHRC"
    echo "  enabled oh-my-zsh git plugin in ${ZSHRC}"
  fi
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
echo "  gsclean     — remove tracked branches that no longer exist locally"
echo "  gsupdate    — update gswitch to the latest version"
