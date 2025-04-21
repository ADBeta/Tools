#!/bin/bash

# Prints the CPU Cores a passed proc name is running on (Built for BusyBox Shell)
# Usage: get_proc_cores.sh [program_name]
# (c) ADBeta    10 Feb 2025
name=$1
procs="$(pgrep -f $name)"

for process in $procs
do
	core="$(ps -o pid,psr,comm -p $process | tr -d "\n\r" | awk '{print $5}')"
	
	
	echo "Process $process: Running on core: $core"
done
