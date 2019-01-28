#!/bin/bash
DISK=(`df /home/|tr -s ' ' |cut -d' ' -f5|tail -n1|sed 's/%//'`)

MEM=(`free -t | grep "buffers/cache" | awk '{print $4/($3+$4) * 100}'`)
int=${MEM%.*}
WHOLE=100
MEM=$((WHOLE-int))

PREV_TOTAL=0
PREV_IDLE=0

# Get the total CPU statistics, discarding the 'cpu ' prefix.
CPU=(`sed -n 's/^cpu\s//p' /proc/stat`)
IDLE=${CPU[3]} # Just the idle CPU time.

# Calculate the total CPU time.
TOTAL=0
for VALUE in "${CPU[@]}"; do
   let "TOTAL=$TOTAL+$VALUE"
done

# Calculate the CPU usage since we last checked.
let "DIFF_IDLE=$IDLE-$PREV_IDLE"
let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
CPU="$DIFF_USAGE"

echo "$CPU:$MEM:$DISK"
