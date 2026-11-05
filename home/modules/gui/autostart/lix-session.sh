# lix-session: start/stop the lix graphical session (see default.nix).
#   lix-session start        run once by the compositor at startup
#   lix-session watch <id>   (internal) wait for logind session <id> to end
#   lix-session stop         stop the session's services by hand

watch_unit=lix-session-watch.service

stop_session() {
  systemctl --user stop lix-session.target graphical-session.target || true
}

case "${1:-}" in
start)
  session="${XDG_SESSION_ID:-}"
  if [ -z "$session" ]; then
    echo "lix-session: XDG_SESSION_ID not set; services won't be stopped on logout" >&2
  fi

  if systemctl --user is-active --quiet "$watch_unit"; then
    watched=$(systemctl --user show "$watch_unit" -p Description --value)
    if [ "$watched" = "lix session ${session}" ]; then
      echo "lix-session: already running for session $session (nested compositor?), doing nothing" >&2
      exit 0
    fi
    # Watcher for an older, ending session: stop it so it can't stop ours.
    systemctl --user stop "$watch_unit" || true
  fi

  systemctl --user reset-failed
  dbus-update-activation-environment --systemd --all

  # Restart so services from a previous session pick up the new environment.
  systemctl --user stop lix-session.target || true
  systemctl --user start lix-session.target

  if [ -n "$session" ]; then
    systemd-run --user --quiet --collect \
      --unit="$watch_unit" \
      --description="lix session ${session}" \
      "$(readlink -f "$0")" watch "$session"
  fi
  ;;

watch)
  session="$2"
  # Poll logind until the session is gone or closing (logout/crash).
  while state=$(loginctl show-session "$session" -p State --value 2>/dev/null) &&
    [ "$state" != closing ]; do
    sleep 2
  done
  stop_session
  ;;

stop)
  systemctl --user stop "$watch_unit" || true
  stop_session
  ;;

*)
  echo "usage: lix-session start|stop" >&2
  exit 1
  ;;
esac
