#!/bin/sh

case "$(pidof dropbear | wc -w)" in
# Add the desired dropbear options here
0) dropbearmulti dropbear -R -F -K 15 -s &
   ;;
*) ;;
esac

exit 0
