#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

MGTTD=${MGTTD:-$SRCDIR/miningTTd}
MGTTCLI=${MGTTCLI:-$SRCDIR/miningTT-cli}
MGTTTX=${MGTTTX:-$SRCDIR/miningTT-tx}
MGTTQT=${MGTTQT:-$SRCDIR/qt/miningTT-qt}

[ ! -x $MGTTD ] && echo "$MGTTD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
MGTTVER=($($MGTTCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$MGTTD --version | sed -n '1!p' >> footer.h2m

for cmd in $MGTTD $MGTTCLI $MGTTTX $MGTTQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${MGTTVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${MGTTVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m