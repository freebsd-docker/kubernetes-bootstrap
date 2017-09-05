#!/bin/sh
############################################################ IDENT(1)
#
# $Title: Script to enable client side hooks $
# $Copyright: 2017 Devin Teske. All rights reserved. $
# $GitHub: .git-hooks/install.sh 2017-09-05 11:08:32 +0000 unknown $
#
############################################################ GLOBALS

progdir="${0%/*}" # Program directory

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
# Make symlinks in .git directory
#
for file in $( find "$progdir" \
	-type f -and \
	-not -name '*.sh' \
	-and -not -name '.*' \
	-and -not -name '*[^[:alnum:]_-]*' \
	-and -perm +0111 \
	| sed -e 's#.*/##'
); do
	eval2 ln -sfv ../../.git-hooks/$file .git/hooks
done

#
# Done
#
eval2 : SUCCESS

################################################################################
# END
################################################################################
