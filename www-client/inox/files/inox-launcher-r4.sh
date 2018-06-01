#!/bin/bash

# Allow the user to override command-line flags, bug #357629.
# This is based on Debian's chromium-browser package, and is intended
# to be consistent with Debian.
for f in /etc/inox/*; do
    [[ -f ${f} ]] && source "${f}"
done

# Prefer user defined INOX_USER_FLAGS (from env) over system
# default INOX_FLAGS (from /etc/inox/default).
INOX_FLAGS=${INOX_USER_FLAGS:-"$INOX_FLAGS"}

# Let the wrapped binary know that it has been run through the wrapper
export INOX_WRAPPER=$(readlink -f "$0")

PROGDIR=${INOX_WRAPPER%/*}

case ":$PATH:" in
  *:$PROGDIR:*)
    # $PATH already contains $PROGDIR
    ;;
  *)
    # Append $PROGDIR to $PATH
    export PATH="$PATH:$PROGDIR"
    ;;
esac

if [[ ${EUID} == 0 && -O ${XDG_CONFIG_HOME:-${HOME}} ]]; then
	# Running as root with HOME owned by root.
	# Pass --user-data-dir to work around upstream failsafe.
	INOX_FLAGS="--user-data-dir=${XDG_CONFIG_HOME:-${HOME}/.config}/inox
		${INOX_FLAGS}"
fi

# Set the .desktop file name
export CHROME_DESKTOP="inox-browser-inox.desktop"

exec -a "inox-browser" "$PROGDIR/inox" --extra-plugin-dir=/usr/lib/nsbrowser/plugins ${INOX_FLAGS} "$@"
