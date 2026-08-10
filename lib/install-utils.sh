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

# Git Bash/MSYS on Windows falls back to copying when it cannot create a native
# symlink. The copies are snapshots that never track the repo, and re-running
# skips them because they are not links we own, so an install silently freezes
# at whatever it was on its first run. Detect it quietly; report_install_health
# decides whether it is worth telling the user. On Windows this is a property of
# the process, not of a directory, so one probe answers for every destination.
# Only a *successful* ln that yields a non-symlink means copying: an ln that
# failed outright copied nothing, and reporting that as copying would send the
# user after the wrong problem.
check_symlink_support() {
  local probe="${AGENTS_DIR}/.symlink-probe.$$"
  # Sweep first: cleanup below only knows the current PID, so an interrupted
  # earlier run would leave its probe behind forever.
  rm -rf -- "${AGENTS_DIR}"/.symlink-probe.*
  : > "${probe}.target"
  if ln -s -- "${probe}.target" "$probe" 2>/dev/null && [ ! -L "$probe" ]; then
    SYMLINKS_REAL=0
  fi
  rm -rf -- "$probe" "${probe}.target"
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
      ln -s -- "$src" "$dest"
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

  ln -s -- "$src" "$dest"
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
    echo "Warning: this shell copies instead of creating symlinks (typical for Git Bash on" >&2
    echo "  Windows). The installed entries are snapshots that do not follow this repo, so" >&2
    echo "  re-run with --force after updating it to refresh them." >&2
  elif [ "$NOTHING_INSTALLED" -eq 1 ]; then
    echo "Nothing was installed: the names are held by entries this script does not own." >&2
    echo "  Re-run with --force to replace them (this deletes what is currently there)." >&2
  fi
}
