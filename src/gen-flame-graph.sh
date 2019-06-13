#!/bin/bash

# Usage: ./gen-flame-graph.sh -p pid -t time -o output

while getopts "p:t:o:" arg; do
    case ${arg} in
        p) PID="$OPTARG" ;;
        t) TIME="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        ?) echo "Usage: $0 -p pid -t time(seconds) -o output" && exit 1 ;;
    esac
done

if [[ -z "$PID" || -z "$TIME" || -z "$OUTPUT" ]]; then
    echo "Usage: $0 -p pid -t time(seconds) -o output"
    exit 1
fi

# clean env
rm -f "$OUTPUT"

echo "Getting stacktraces from process $PID... will stop on ^C or when the process exits."

# Collect stack info

STACK_OUTPUT="flamegraph-stacks-out.txt"

END_TIME=$((SECONDS+TIME))
while [[ $SECONDS -lt ${END_TIME} ]]; do
    jstack "$PID" >> "$STACK_OUTPUT" && sleep 0.1 || break
done

echo "Done! stacks saved to $STACK_OUTPUT"

# Collapse stack and generate flame graph
./stackcollapse-jstack.pl ${STACK_OUTPUT} | ./flamegraph.pl > ${OUTPUT}

#rm -f palette.map
rm -f ${STACK_OUTPUT}

echo "Done! Now see the output in ${OUTPUT}"
