# Helpers shared by ./install.sh and ./install-opinionated-rules.sh.
#
# Sourced, not run. Callers set REPO_DIR, AGENTS_DIR, and FORCE before using
# the functions below.

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "This file provides helpers sourced by the installers; run ./install.sh or ./install-opinionated-rules.sh instead." >&2
  exit 1
fi

# Link targets embed AGENTS_DIR and is_ours compares path prefixes, so it
# must be absolute.
resolve_agents_dir() {
  mkdir -p "$AGENTS_DIR"
  AGENTS_DIR="$(cd "$AGENTS_DIR" && pwd -P)"
}

SYMLINKS_REAL=1
NOTHING_INSTALLED=0
PHASE_DONE=0
PHASE_SKIPPED=0

WINDOWS=0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;;
esac

# Link $1 to $2, the best way this environment allows.
#
# Git Bash/MSYS silently copies instead of linking unless the process may create
# native symlinks, which takes Developer Mode or elevation; nativestrict turns
# that silent copy into an error we can fall back from. A directory junction is
# the fallback: it needs no privilege, and MSYS reads one back as a symlink, so
# readlink, -L and rm behave as the rest of this file assumes. Junctions cover
# directories on a local NTFS volume only, hence the plain ln -s last resort,
# which copies.
make_link() {
  local src="$1" dest="$2"
  if [ "$WINDOWS" -eq 1 ]; then
    MSYS=winsymlinks:nativestrict ln -s -- "$src" "$dest" 2>/dev/null && return 0
    if [ -d "$src" ] && command -v cygpath >/dev/null 2>&1; then
      MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
        cmd /c mklink /J "$(cygpath -w "$dest")" "$(cygpath -w "$src")" >/dev/null 2>&1 && return 0
    fi
  fi
  ln -s -- "$src" "$dest"
}

# Whether make_link really links here, probed with the kind of source the caller
# installs ($1: dir or file) — junctions cover directories but not files, so the
# answer differs per installer. The copies are snapshots that never track the
# repo, and re-running skips them because they are not links we own, so an
# install silently freezes at whatever it was on its first run. Detect it
# quietly; report_install_health decides whether to tell the user. Only a
# *successful* link attempt that yields a non-symlink means copying: one that
# failed outright copied nothing, and reporting that as copying would send the
# user after the wrong problem.
check_symlink_support() {
  local kind="$1" probe_dir link
  # Own dir, so the cleanup below can't touch a concurrent installer's probe or
  # anything the user keeps here. If mktemp fails, stay quiet rather than guess.
  probe_dir="$(mktemp -d "${AGENTS_DIR}/.symlink-probe.XXXXXX" 2>/dev/null)" || return 0
  link="${probe_dir}/link"
  if [ "$kind" = dir ]; then
    mkdir "${probe_dir}/target"
  else
    : > "${probe_dir}/target"
  fi
  if make_link "${probe_dir}/target" "$link" 2>/dev/null && [ ! -L "$link" ]; then
    SYMLINKS_REAL=0
  fi
  rm -rf -- "$probe_dir"
}

# A symlink is "ours" if it points into this repo clone or the agents dir.
is_ours() {
  local target
  target="$(readlink "$1")" || return 1
  [[ "$target" == "${REPO_DIR}"/* || "$target" == "${AGENTS_DIR}"/* ]]
}

# Remove broken symlinks we own from directory $1. Broken foreign symlinks
# are left alone.
prune_dir() {
  local dir="$1" entry
  [ -d "$dir" ] || return 0
  for entry in "$dir"/*; do
    { [ -L "$entry" ] && [ ! -e "$entry" ]; } || continue
    is_ours "$entry" || continue
    rm "$entry"
    echo "  prune  $(basename "$entry")"
  done
}

# Symlink $1 into directory $2, respecting --force.
link_one() {
  local src="$1" dest_dir="$2"
  local name dest
  name="$(basename "$src")"
  dest="${dest_dir}/${name}"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  ok     ${name}"
    PHASE_DONE=$((PHASE_DONE + 1))
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && is_ours "$dest"; then
      rm -- "$dest"
      make_link "$src" "$dest"
      echo "  relink ${name}"
      PHASE_DONE=$((PHASE_DONE + 1))
      return
    fi
    if [ "$FORCE" -eq 1 ]; then
      rm -rf -- "$dest"
    else
      echo "  skip   ${name} (already exists; use --force to overwrite)"
      count_skip
      return
    fi
  fi

  make_link "$src" "$dest"
  echo "  link   ${name}"
  PHASE_DONE=$((PHASE_DONE + 1))
}

# An entry the caller gave up on before link_one saw it.
count_skip() {
  PHASE_SKIPPED=$((PHASE_SKIPPED + 1))
}

# Phases are counted separately: a phase that installed nothing is worth
# reporting even when the other one did work, since the install as a whole is
# then wired to something this repo did not put there.
begin_phase() {
  PHASE_DONE=0
  PHASE_SKIPPED=0
}

end_phase() {
  if [ "$PHASE_SKIPPED" -gt 0 ] && [ "$PHASE_DONE" -eq 0 ]; then
    NOTHING_INSTALLED=1
  fi
  return 0
}

# Silent unless the run needs something from the user. Two cases qualify: an
# environment that cannot link, where the install looks fine but will never
# update itself, and a phase that installed nothing at all, which otherwise
# reads as a successful no-op. A run that got its work done stays quiet.
report_install_health() {
  if [ "$SYMLINKS_REAL" -eq 0 ]; then
    echo "Warning: this environment copies instead of linking, so the installed entries are" >&2
    echo "  snapshots that do not follow this repo; re-run with --force after updating it to" >&2
    echo "  refresh them. On Windows, links to single files (the rules) need Developer Mode or" >&2
    echo "  an elevated shell, while links to directories (the skills) fall back to junctions" >&2
    echo "  and need neither." >&2
  elif [ "$NOTHING_INSTALLED" -eq 1 ]; then
    echo "The install names are held by entries this script does not own, so the installed" >&2
    echo "  content will not follow this repo. Re-run with --force to replace those entries" >&2
    echo "  (this deletes what is currently there)." >&2
  fi
}
