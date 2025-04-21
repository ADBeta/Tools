#!/bin/sh

# Prints all oprhaned processed on the system (Built for BusyBox Shell)
# (c) ADBeta    10 Feb 2025

orphans="$(ps -ef | awk '$3 == 1{ print $2; }')"
echo "Orphan Processes:"
echo "$orphans"
