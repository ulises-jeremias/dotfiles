#!/usr/bin/env sh

# -e: exit on error
# -u: exit on unset variables
set -eu

log_color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

log_red() {
  log_color "0;31" "$@"
}

log_blue() {
  log_color "0;34" "$@"
}

log_task() {
  log_blue "🔃" "$@"
}

log_manual_action() {
  log_red "⚠️" "$@"
}

log_error() {
  log_red "❌" "$@"
}

error() {
  log_error "$@"
  exit 1
}

sudo() {
  # shellcheck disable=SC2312
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    if ! command sudo --non-interactive true 2>/dev/null; then
      log_manual_action "Root privileges are required, please enter your password below"
      command sudo --validate
    fi
    command sudo "$@"
  fi
}

update_dotfiles_fast_forward() {
  path=$(realpath "$1")
  remote="$2"
  branch="$3"

  if ! git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    error "'${path}' exists but is not a Git repository; it was left untouched."
  fi

  current_branch=$(git -C "$path" symbolic-ref --quiet --short HEAD || true)
  if [ "$current_branch" != "$branch" ]; then
    error "'${path}' is on '${current_branch:-detached HEAD}', not '${branch}'. No checkout or cleanup was performed."
  fi

  if [ -n "$(git -C "$path" status --porcelain)" ]; then
    error "'${path}' has local changes. Commit or back them up before updating; no files were changed."
  fi

  log_task "Updating '${path}' from '${remote}' with a fast-forward to '${branch}'"
  if ! git -C "$path" fetch "$remote" "$branch"; then
    error "Could not fetch '${branch}' from '${remote}'; '${path}' was left unchanged."
  fi
  if ! git -C "$path" merge --ff-only FETCH_HEAD; then
    error "'${path}' has diverged from '${remote}/${branch}'. Reconcile it manually; no history was rewritten."
  fi
  unset path remote branch current_branch
}

DOTFILES_REPO_HOST=${DOTFILES_REPO_HOST:-"https://github.com"}
DOTFILES_USER=${DOTFILES_USER:-"ulises-jeremias"}
DOTFILES_REPO=${DOTFILES_REPO:-"${DOTFILES_REPO_HOST}/${DOTFILES_USER}/dotfiles"}
DOTFILES_BRANCH=${DOTFILES_BRANCH:-"main"}
DOTFILES_DIR=${DOTFILES_DIR:-"${HOME}/.dotfiles"}

if ! command -v git >/dev/null 2>&1; then
  error "Git is not installed"
fi

if ! command -v horneroctl >/dev/null 2>&1; then
  log_manual_action "horneroctl not found (optional): dots-* shims prefer it when present and fall back to legacy implementations otherwise. Build it from https://github.com/HorneroOS/hornero (see docs/Horneroctl.md) or point HORNEROCTL_BIN at a custom binary path."
fi

if [ -d "${DOTFILES_DIR}" ]; then
  update_dotfiles_fast_forward "${DOTFILES_DIR}" "${DOTFILES_REPO}" "${DOTFILES_BRANCH}"
else
  log_task "Cloning '${DOTFILES_REPO}' at branch '${DOTFILES_BRANCH}' to '${DOTFILES_DIR}'"
  git clone --branch "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" "${DOTFILES_DIR}"
fi

if [ -f "${DOTFILES_DIR}/install.sh" ]; then
  INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"
elif [ -f "${DOTFILES_DIR}/install" ]; then
  INSTALL_SCRIPT="${DOTFILES_DIR}/install"
else
  error "No install script found in the dotfiles."
fi

log_task "Running '${INSTALL_SCRIPT}'"
exec "${INSTALL_SCRIPT}" "$@"
