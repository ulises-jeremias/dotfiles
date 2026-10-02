#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
installer="${repo_root}/scripts/install_dotfiles.sh"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

remote="${tmp}/canonical.git"
seed="${tmp}/seed"
home="${tmp}/home-existing"
dotfiles="${home}/.dotfiles"
new_home="${tmp}/home-new"
new_dotfiles="${new_home}/.dotfiles"
branch_home="${tmp}/home-branch"
branch_dotfiles="${branch_home}/.dotfiles"

mkdir -p "$seed" "$home" "$new_home" "$branch_home"
git init --bare --initial-branch=main "$remote" >/dev/null
git -C "$seed" init --initial-branch=main >/dev/null
git -C "$seed" config user.name "Dotfiles sync test"
git -C "$seed" config user.email "sync-test@example.invalid"

cat > "${seed}/install.sh" <<'EOF'
#!/usr/bin/env sh
printf 'ran\n' > "$HOME/install-script-ran"
EOF
chmod +x "${seed}/install.sh"
printf 'initial\n' > "${seed}/managed.txt"
git -C "$seed" add install.sh managed.txt
git -C "$seed" commit -m "test fixture"
git -C "$seed" remote add origin "$remote"
git -C "$seed" push -u origin main >/dev/null

git clone --branch main "$remote" "$dotfiles" >/dev/null 2>&1
git -C "$dotfiles" config user.name "Dotfiles sync test"
git -C "$dotfiles" config user.email "sync-test@example.invalid"

# A clean existing checkout must fast-forward and then run its installer.
printf 'upstream update\n' > "${seed}/upstream.txt"
git -C "$seed" add upstream.txt
git -C "$seed" commit -m "upstream update"
git -C "$seed" push origin main >/dev/null
HOME="$home" DOTFILES_REPO="$remote" DOTFILES_DIR="$dotfiles" "$installer" >/dev/null
test "$(git -C "$dotfiles" rev-parse HEAD)" = "$(git -C "$seed" rev-parse HEAD)"
test -f "${dotfiles}/upstream.txt"
test "$(cat "${home}/install-script-ran")" = "ran"

# An existing user's edits must stop the update without changing their data.
printf 'owner data\n' > "${dotfiles}/managed.txt"
before="$(git -C "$dotfiles" rev-parse HEAD)"
printf 'second upstream update\n' > "${seed}/second-upstream.txt"
git -C "$seed" add second-upstream.txt
git -C "$seed" commit -m "second upstream update"
git -C "$seed" push origin main >/dev/null
rm "${home}/install-script-ran"
if HOME="$home" DOTFILES_REPO="$remote" DOTFILES_DIR="$dotfiles" "$installer" >/dev/null 2>&1; then
  echo "expected dirty dotfiles checkout to be preserved and rejected" >&2
  exit 1
fi
test "$(cat "${dotfiles}/managed.txt")" = "owner data"
test "$(git -C "$dotfiles" rev-parse HEAD)" = "$before"
test ! -e "${dotfiles}/second-upstream.txt"
test ! -e "${home}/install-script-ran"

# A different branch must not be silently checked out or reset to main.
git clone --branch main "$remote" "$branch_dotfiles" >/dev/null 2>&1
git -C "$branch_dotfiles" checkout -b owner-work >/dev/null 2>&1
before="$(git -C "$branch_dotfiles" rev-parse HEAD)"
if HOME="$branch_home" DOTFILES_REPO="$remote" DOTFILES_DIR="$branch_dotfiles" "$installer" >/dev/null 2>&1; then
  echo "expected non-main dotfiles branch to be preserved and rejected" >&2
  exit 1
fi
test "$(git -C "$branch_dotfiles" branch --show-current)" = "owner-work"
test "$(git -C "$branch_dotfiles" rev-parse HEAD)" = "$before"
test ! -e "${branch_home}/install-script-ran"

# A new machine without ~/.dotfiles must clone the configured branch.
HOME="$new_home" DOTFILES_REPO="$remote" DOTFILES_DIR="$new_dotfiles" "$installer" >/dev/null
test "$(git -C "$new_dotfiles" rev-parse HEAD)" = "$(git -C "$seed" rev-parse HEAD)"
test -f "${new_dotfiles}/second-upstream.txt"
test "$(cat "${new_home}/install-script-ran")" = "ran"

echo "install_dotfiles sync tests passed"
