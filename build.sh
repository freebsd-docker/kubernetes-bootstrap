#!/bin/sh
############################################################ IDENT(1)
#
# $Title: Script to build kubernetes tools on FreeBSD $
# $Copyright: 2017 Devin Teske. All rights reserved. $
# $GitHub: freebsd-docker/kubernetes-bootstrap.git build.sh 2017-09-05 19:14:27 +0000 freebsdfrau $
#
############################################################ GLOBALS

#
# Stdout processing
#
CONSOLE=
[ -t 0 ] && CONSOLE=1 # Output is to a terminal (vs pipe, etc.)

#
# ANSI
#
ESC=$( :| awk 'BEGIN { printf "%c", 27 }' )
ANSI_BLD_ON="${CONSOLE:+$ESC[1m}"
ANSI_BLD_OFF="${CONSOLE:+$ESC[22m}"
ANSI_GRN_ON="${CONSOLE:+$ESC[32m}"
ANSI_FGC_OFF="${CONSOLE:+$ESC[39m}"

############################################################ FUNCTIONS

eval2()
{
	echo "$ANSI_BLD_ON$ANSI_GRN_ON==>$ANSI_FGC_OFF $*$ANSI_BLD_OFF"
	eval "$@"
}

############################################################ MAIN

set -e # Make all errors fatal

#
# Install dependencies
#
items_needed=
ldconfig_restart=
#	bin=someprog:pkg=somepkg \
#	file=/path/to/some_file:pkg=somepkg \
#	lib=somelib.so:pkg=somepkg \
for entry in \
	bin=gmake:pkg=gmake \
	bin=go:pkg=go \
; do
	check="${entry%%:*}"
	item="${check#*=}"
	case "$check" in
	 bin=*) type "$item" > /dev/null 2>&1 && continue ;;
	file=*) [ -e "$item" ] && continue ;;
	 lib=*) ldconfig -p |
			awk -v lib="$item" '$1==lib{exit f++}END{exit !f}' &&
			continue
		ldconfig_restart=1 ;;
	     *) continue
	esac
	pkg="${entry#*:}"
	pkgname="${pkg#*=}"
	items_needed="$items_needed $pkgname"
done
if [ "$items_needed" ]; then
	eval2 sudo pkg install $items_needed
	[ "$ldconfig_restart" ] && eval2 service ldconfig restart
fi

#
# Build software
#
eval2 time gmake

#
# Done
#
eval2 : SUCCESS

################################################################################
# END
################################################################################
