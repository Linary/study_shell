#!/bin/bash

# Usage: ./profile.sh pid output.txt

PROFILED_PID=$1
OUTPUT_FILE=$2

echo "Getting stacktraces from process $PROFILED_PID... will stop on ^C or when the process exits."

rm -f "$OUTPUT_FILE"

while true; do
    jstack "$PROFILED_PID" >> "$OUTPUT_FILE" && sleep 0.1 || break
done

echo
echo "Done! stacks saved to $OUTPUT_FILE"
