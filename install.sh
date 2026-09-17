#!/usr/bin/env bash
# Symlinks the dotfiles in this repo into $HOME.
# Safe to re-run: already-correct symlinks are skipped, and anything else
# found at the target path is backed up before being replaced.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d%H%M%S)"

# repo path (relative to this dir) -> target path (relative to $HOME)
LINKS=(
  "zshrc:.zshrc"
  "zshenv:.zshenv"
  "zprofile:.zprofile"
  "p10k.zsh:.p10k.zsh"
  "vimrc:.vimrc"
  "yarnrc:.yarnrc"
  "gitconfig:.gitconfig"
  "gitignore:.gitignore"
  "config/git/ignore:.config/git/ignore"
  "config/nvim:.config/nvim"
  "config/wezterm:.config/wezterm"
)

backup_needed=false

for entry in "${LINKS[@]}"; do
  src="$DOTFILES_DIR/${entry%%:*}"
  target="$HOME/${entry##*:}"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
    echo "ok      ${entry##*:} (already linked)"
    continue
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$backup_needed" = false ]; then
      mkdir -p "$BACKUP_DIR"
      backup_needed=true
    fi
    mkdir -p "$(dirname "$BACKUP_DIR/${entry##*:}")"
    mv "$target" "$BACKUP_DIR/${entry##*:}"
    echo "backup  ${entry##*:} -> ${BACKUP_DIR/#$HOME/~}/${entry##*:}"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$src" "$target"
  echo "linked  ${entry##*:} -> ${src/#$HOME/~}"
done

if [ "$backup_needed" = true ]; then
  echo
  echo "Backed up pre-existing files to: ${BACKUP_DIR/#$HOME/~}"
fi
