#!/bin/sh

case "$(pidof dropbear | wc -w)" in
# Add the desired dropbear options here
0) dropbear -R -F -K 15 &
   ;;
*) ;;
esac

exit 0
